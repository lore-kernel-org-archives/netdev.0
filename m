From: Dominick Grift <dac.override@gmail.com>
Subject: Re: Suspicious RCU usage in bridge with Linux v4.0-9362-g1fc149933fd4
Date: Mon, 4 May 2015 15:39:44 +0200
Message-ID: <20150504133943.GA17043@x131e>
References: <CA+5PVA5gE_pG5iPKBgugsEjLsOYvq9bWKfB+2OeEujjdOb+URg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha512;
	protocol="application/pgp-signature"; boundary="8t9RHnE3ZwKMSgU+"
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f178.google.com ([209.85.212.178]:35251 "EHLO
	mail-wi0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752116AbbEDNjr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 May 2015 09:39:47 -0400
Received: by widdi4 with SMTP id di4so121888544wid.0
        for <netdev@vger.kernel.org>; Mon, 04 May 2015 06:39:46 -0700 (PDT)
Received: from x131e (217-19-24-195.dsl.cambrium.nl. [217.19.24.195])
        by mx.google.com with ESMTPSA id gy8sm11275391wib.13.2015.05.04.06.39.45
        for <netdev@vger.kernel.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 04 May 2015 06:39:45 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <CA+5PVA5gE_pG5iPKBgugsEjLsOYvq9bWKfB+2OeEujjdOb+URg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--8t9RHnE3ZwKMSgU+
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Thu, Apr 23, 2015 at 01:07:45PM -0400, Josh Boyer wrote:
> Hi All,
>=20
> We've had a user report the following backtrace from the bridge module
> with a recent Linus' tree.  Has anything like this been reported yet?
> If you have any questions on setup, the user is CC'd.
>=20
> josh
>=20
> [   29.382235] br0: port 1(tap0) entered forwarding state
>=20
> [   29.382286] =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
> [   29.382315] [ INFO: suspicious RCU usage. ]
> [   29.382344] 4.1.0-0.rc0.git11.1.fc23.x86_64 #1 Not tainted
> [   29.382380] -------------------------------
> [   29.382409] net/bridge/br_private.h:626 suspicious
> rcu_dereference_check() usage!

<snip>

With 4.1.0-0.rc1.git1.1.fc23.x86_64 the situation seems to have slightly ch=
anged:

May 04 14:51:34 d30 kernel: =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
May 04 14:51:34 d30 kernel: [ INFO: suspicious RCU usage. ]
May 04 14:51:34 d30 kernel: 4.1.0-0.rc1.git1.1.fc23.x86_64 #1 Not tainted
May 04 14:51:34 d30 kernel: -------------------------------
May 04 14:51:34 d30 kernel: net/bridge/br_private.h:626 suspicious rcu_dere=
ference_check() usage!
May 04 14:51:34 d30 kernel:
May 04 14:51:34 d30 kernel:
May 04 14:51:34 d30 kernel: 3 locks held by qemu-system-x86/1133:
May 04 14:51:34 d30 kernel:  #0:  (&vcpu->mutex){+.+.+.}, at: [<ffffffffa06=
a7e16>] vcpu_load+0x26/0x70 [kvm]
May 04 14:51:34 d30 kernel:  #1:  (((&p->forward_delay_timer))){+.-...}, at=
: [<ffffffff81139db5>] call_timer_fn+0x5/0x4f0
May 04 14:51:34 d30 kernel:  #2:  (&(&br->lock)->rlock){+.-...}, at: [<ffff=
ffffa04aedc1>] br_forward_delay_timer_expired+0x31/0x140 [bridge]
May 04 14:51:34 d30 kernel:
May 04 14:51:34 d30 kernel: CPU: 6 PID: 1133 Comm: qemu-system-x86 Not tain=
ted 4.1.0-0.rc1.git1.1.fc23.x86_64 #1
May 04 14:51:34 d30 kernel: Hardware name: LENOVO 422916G/LENOVO, BIOS A1KT=
53AUS 04/07/2015
May 04 14:51:34 d30 kernel:  0000000000000000 000000000dce176d ffff880c65e0=
3c48 ffffffff81893b45
May 04 14:51:34 d30 kernel:  0000000000000000 ffff880c5e869a60 ffff880c65e0=
3c78 ffffffff8110bb17
May 04 14:51:34 d30 kernel:  ffff880c56f6f700 ffff880c61a35c58 ffff880c5c14=
d000 ffff88065b470ac0
May 04 14:51:34 d30 kernel: Call Trace:
May 04 14:51:34 d30 kernel:  <IRQ>  [<ffffffff81893b45>] dump_stack+0x4c/0x=
65
May 04 14:51:34 d30 kernel:  [<ffffffff8110bb17>] lockdep_rcu_suspicious+0x=
e7/0x120
May 04 14:51:34 d30 kernel:  [<ffffffffa04b00f9>] br_fill_ifinfo+0x4a9/0x6a=
0 [bridge]
May 04 14:51:34 d30 kernel:  [<ffffffffa04b066b>] br_ifinfo_notify+0x11b/0x=
4b0 [bridge]
May 04 14:51:34 d30 kernel:  [<ffffffffa04aed90>] ? br_hold_timer_expired+0=
x70/0x70 [bridge]
May 04 14:51:34 d30 kernel:  [<ffffffffa04aede8>] br_forward_delay_timer_ex=
pired+0x58/0x140 [bridge]
May 04 14:51:34 d30 kernel:  [<ffffffffa04aed90>] ? br_hold_timer_expired+0=
x70/0x70 [bridge]
May 04 14:51:34 d30 kernel:  [<ffffffff81139e73>] call_timer_fn+0xc3/0x4f0
May 04 14:51:34 d30 kernel:  [<ffffffff81139db5>] ? call_timer_fn+0x5/0x4f0
May 04 14:51:34 d30 kernel:  [<ffffffff8189cb50>] ? _raw_spin_unlock_irq+0x=
30/0x50
May 04 14:51:34 d30 kernel:  [<ffffffffa04aed90>] ? br_hold_timer_expired+0=
x70/0x70 [bridge]
May 04 14:51:34 d30 kernel:  [<ffffffff8113a4e4>] run_timer_softirq+0x244/0=
x490
May 04 14:51:34 d30 kernel:  [<ffffffff810b6847>] ? __do_softirq+0xb7/0x670
May 04 14:51:34 d30 kernel:  [<ffffffff810b687c>] __do_softirq+0xec/0x670
May 04 14:51:34 d30 kernel:  [<ffffffffa12b1380>] ? vmx_invpcid_supported+0=
x30/0x30 [kvm_intel]
May 04 14:51:34 d30 kernel:  [<ffffffff810b7085>] irq_exit+0x145/0x150
May 04 14:51:34 d30 kernel:  [<ffffffff818a0546>] smp_apic_timer_interrupt+=
0x46/0x60
May 04 14:51:34 d30 kernel:  [<ffffffff8189e4f0>] ? uv_bau_message_intr1+0x=
80/0x80
May 04 14:51:34 d30 kernel:  [<ffffffff8189e563>] apic_timer_interrupt+0x73=
/0x80
May 04 14:51:34 d30 kernel:  <EOI>  [<ffffffffa12bf3a1>] ? vmx_vcpu_run+0x8=
71/0x8a0 [kvm_intel]
May 04 14:51:34 d30 kernel:  [<ffffffff8189e4f0>] ? uv_bau_message_intr1+0x=
80/0x80
May 04 14:51:34 d30 kernel:  [<ffffffffa12b236f>] ? vmx_handle_external_int=
r+0x6f/0x70 [kvm_intel]
May 04 14:51:34 d30 kernel:  [<ffffffffa06c1fff>] ? kvm_arch_vcpu_ioctl_run=
+0x71f/0x1ba0 [kvm]
May 04 14:51:34 d30 kernel:  [<ffffffffa06c204f>] ? kvm_arch_vcpu_ioctl_run=
+0x76f/0x1ba0 [kvm]
May 04 14:51:34 d30 kernel:  [<ffffffff8110e1ad>] ? trace_hardirqs_on+0xd/0=
x10
May 04 14:51:34 d30 kernel:  [<ffffffffa06a7e16>] ? vcpu_load+0x26/0x70 [kv=
m]
May 04 14:51:34 d30 kernel:  [<ffffffffa06babe8>] ? kvm_arch_vcpu_load+0x58=
/0x210 [kvm]
May 04 14:51:34 d30 kernel:  [<ffffffffa06a8223>] kvm_vcpu_ioctl+0x383/0x7e=
0 [kvm]
May 04 14:51:34 d30 kernel:  [<ffffffff81027e7d>] ? native_sched_clock+0x2d=
/0xa0
May 04 14:51:34 d30 kernel:  [<ffffffff810db056>] ? creds_are_invalid.part.=
1+0x16/0x50
May 04 14:51:34 d30 kernel:  [<ffffffff810db0b1>] ? creds_are_invalid+0x21/=
0x30
May 04 14:51:34 d30 kernel:  [<ffffffff813b56fa>] ? inode_has_perm.isra.48+=
0x2a/0xa0
May 04 14:51:34 d30 kernel:  [<ffffffff81298558>] do_vfs_ioctl+0x2e8/0x530
May 04 14:51:34 d30 kernel:  [<ffffffff81298821>] SyS_ioctl+0x81/0xa0
May 04 14:51:34 d30 kernel:  [<ffffffff8189d5ee>] system_call_fastpath+0x12=
/0x76
May 04 14:51:34 d30 kernel: br0: port 1(tap0) entered forwarding state
May 04 14:51:34 d30 kernel: br0: port 3(tap2) entered forwarding state
May 04 14:51:34 d30 kernel: br0: port 4(tap3) entered forwarding state=20

--=20
02DFF788
4D30 903A 1CF3 B756 FB48  1514 3148 83A2 02DF F788
http://keys.gnupg.net/pks/lookup?op=3Dvindex&search=3D0x314883A202DFF788
Dominick Grift

--8t9RHnE3ZwKMSgU+
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQGcBAEBCgAGBQJVR3aZAAoJENAR6kfG5xmcR/IMALh3GAUtmTQkltKHo6FNIGdJ
FbGZL8ELedSOYmLa8lJrzSZhxouCg6f5yXNLOXAWgt8x06MRzWsUkAJxNNKinWpH
2B/Cggy5hZVkY89Dkyam0OTeu21WR4Z58JWxyYkt2G3RplndEynXO6IDVMp8bkcQ
btpRxShZdV+SMrPoDHvxdH/OOii0jbLNv6oZl5TGAIpTVyOYSGx5VbVye2zUL/yD
ERctuIWwfJShmQ52Gfa9cAxzoGHNEiXWNZGJd7legwDJh8LfmHJ+B76BoccrKUKI
3FePQwSHQQaNodONmIH4/B/p/FHbiJFXcaFwpiIip5zJDH3lV/eEtKjALoA2incE
bDcRuGCRbSJW0UifbkpZOORdPJsuJe70nhtxAHJ+HEXUlXqnINd0EVCRvoEvd+jB
02T/OBtwIj/ojb3mbvCGICcFfKEzSwALOHu5agSF7PmBbl66VqtZUmjrEXBD2paI
ab97HmPSdRwyab7fNclV2fETewG7fz+wDqWSR7miAA==
=FkYA
-----END PGP SIGNATURE-----

--8t9RHnE3ZwKMSgU+--
