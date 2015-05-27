From: Nikola Ciprich <nikola.ciprich@linuxbox.cz>
Subject: 4.0.4 - bnx2x - DEBUG_LOCKS_WARN_ON(in_interrupt())
Date: Wed, 27 May 2015 18:10:37 +0200
Message-ID: <20150527161037.GF20255@pcnci.linuxbox.cz>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="eNMatiwYGLtwo1cJ"
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from gwu.lbox.cz ([62.245.111.132]:59984 "EHLO gwu.lbox.cz"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751440AbbE0Q0v (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 27 May 2015 12:26:51 -0400
Received: from pcnci.linuxbox.cz (pcnci.linuxbox.cz [10.76.3.14])
	by gwu.lbox.cz (Sendmail) with ESMTPS id t4RGAb5O020532
	(version=TLSv1.2 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=NO)
	for <netdev@vger.kernel.org>; Wed, 27 May 2015 18:10:37 +0200
Received: from pcnci.linuxbox.cz (localhost.localdomain [127.0.0.1])
	by pcnci.linuxbox.cz (8.14.7/8.14.7) with SMTP id t4RGAbRn017725
	for <netdev@vger.kernel.org>; Wed, 27 May 2015 18:10:37 +0200
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--eNMatiwYGLtwo1cJ
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi,

just wanted to report, that I'm getting following trace on 4.0.4 kernel:

[  +0.301517] ------------[ cut here ]------------
[  +0.000227] WARNING: CPU: 0 PID: 0 at kernel/locking/mutex.c:877 mutex_tr=
ylock+0x15d/0x190()
[  +0.000376] DEBUG_LOCKS_WARN_ON(in_interrupt())
[  +0.000072] Modules linked in:
[  +0.000278]  8021q bridge stp llc bonding ipv6 ext3 jbd joydev usbhid vho=
st_net macvtap macvlan vhost tun kvm_intel kvm iTCO_wdt pcspkr sb_edac edac=
_core i2c_i801 sg lpc_i
[  +0.005326] CPU: 0 PID: 0 Comm: swapper/0 Not tainted 4.0.4lb6.00_01_PRE0=
1 #1
[  +0.000226] Hardware name: Supermicro X10DRW/X10DRW-i, BIOS 1.0c 01/07/20=
15
[  +0.000224]  000000000000036d ffff88107fc03cf8 ffffffff814ab37b 000000000=
000036d
[  +0.000619]  ffff88107fc03d48 ffff88107fc03d38 ffffffff8104f715 ffff88107=
fc03e38
[  +0.000618]  ffff8810316adbb0 ffff8810316adbb0 0000000000000002 000000000=
0000001
[  +0.000622] Call Trace:
[  +0.000215]  <IRQ>  [<ffffffff814ab37b>] dump_stack+0x4f/0x74
[  +0.000351]  [<ffffffff8104f715>] warn_slowpath_common+0x95/0xe0
[  +0.000224]  [<ffffffff8104f816>] warn_slowpath_fmt+0x46/0x70
[  +0.000224]  [<ffffffff814acd3d>] mutex_trylock+0x15d/0x190
[  +0.004247]  [<ffffffffa055f7d7>] bnx2x_stats_handle+0x47/0x190 [bnx2x]
[  +0.000230]  [<ffffffffa051107d>] bnx2x_timer+0x19d/0x1b0 [bnx2x]
[  +0.000228]  [<ffffffffa0510ee0>] ? bnx2x_read_fwinfo+0x310/0x310 [bnx2x]
[  +0.000229]  [<ffffffff810ac747>] call_timer_fn+0x47/0x160
[  +0.000224]  [<ffffffff810ad5b8>] run_timer_softirq+0x268/0x2d0
[  +0.000227]  [<ffffffffa0510ee0>] ? bnx2x_read_fwinfo+0x310/0x310 [bnx2x]
[  +0.000227]  [<ffffffff81053963>] __do_softirq+0xf3/0x2d0
[  +0.000224]  [<ffffffff81053bfe>] irq_exit+0x7e/0xa0
[  +0.000223]  [<ffffffff814b344a>] smp_apic_timer_interrupt+0x4a/0x59
[  +0.000225]  [<ffffffff814b191a>] apic_timer_interrupt+0x6a/0x70
[  +0.000223]  <EOI>  [<ffffffff813be6cc>] ? cpuidle_enter_state+0x7c/0x1b0
[  +0.000353]  [<ffffffff813be6b5>] ? cpuidle_enter_state+0x65/0x1b0
[  +0.000224]  [<ffffffff813be817>] cpuidle_enter+0x17/0x20
[  +0.000225]  [<ffffffff81089599>] cpu_startup_entry+0x259/0x440
[  +0.000226]  [<ffffffff814a35f3>] rest_init+0x83/0x90
[  +0.000223]  [<ffffffff81ac318b>] start_kernel+0x3fd/0x40a
[  +0.000223]  [<ffffffff81ac2bac>] ? set_init_arg+0x5d/0x5d
[  +0.000223]  [<ffffffff81ac25ad>] x86_64_start_reservations+0x2a/0x2c
[  +0.000225]  [<ffffffff81ac26fb>] x86_64_start_kernel+0x14c/0x153
[  +0.000223] ---[ end trace 0f28c467beec99ef ]---

It's x86_64 4.0.4 kernel, running on supermicro X10DRW box.

bnx devices are bonded in 802.3ad mode and bond device is member of
bridge..

If I could provide more information, or perform some debugging, please
let me know, I'll have those boxed for few more days for testing here.

BR

nik

--=20
-------------------------------------
Ing. Nikola CIPRICH
LinuxBox.cz, s.r.o.
28.rijna 168, 709 00 Ostrava

tel.:   +420 591 166 214
fax:    +420 596 621 273
mobil:  +420 777 093 799
www.linuxbox.cz

mobil servis: +420 737 238 656
email servis: servis@linuxbox.cz
-------------------------------------

--eNMatiwYGLtwo1cJ
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.14 (GNU/Linux)

iEYEARECAAYFAlVl7H0ACgkQ3xdJJrLygV5m8wCfR8gBll3Jp7fAOZ/uqX/BmcmU
/bgAn2K0umU3mLHyUrxg52MvNlHFXj6/
=LQIB
-----END PGP SIGNATURE-----

--eNMatiwYGLtwo1cJ--
