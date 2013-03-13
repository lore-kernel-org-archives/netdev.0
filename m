From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [E1000-devel] [patch] ixgbe: in shutdown, do netif_running()
 under rtnl_lock
Date: Tue, 12 Mar 2013 23:33:44 -0700
Message-ID: <1363156424.2099.9.camel@jtkirshe-mobl>
References: <20130308220510.GJ21267@riverbed.com>
Reply-To: jeffrey.t.kirsher@intel.com
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-x/NBjTsfcYm8diPSEtAx"
Cc: netdev@vger.kernel.org, e1000-devel@lists.sourceforge.net
To: akepner <akepner@riverbed.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:53173 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755974Ab3CMGeN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 13 Mar 2013 02:34:13 -0400
In-Reply-To: <20130308220510.GJ21267@riverbed.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-x/NBjTsfcYm8diPSEtAx
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Fri, 2013-03-08 at 14:05 -0800, akepner wrote:
>=20
> During shutdown it's possible for __dev_close() (which holds=20
> rtnl_lock) to clear the __LINK_STATE_START bit, and for ixgbe=20
> to then read that bit (without holding rtnl_lock), and then=20
> not fail to free irqs, etc. The result is a crash like this:=20
>=20
> ------------[ cut here ]------------
> kernel BUG at drivers/pci/msi.c:313!
> invalid opcode: 0000 [#1] SMP=20
> last sysfs
> file: /sys/devices/system/cpu/cpu3/cache/index2/shared_cpu_map
> CPU 1=20
> Pid: 5910, comm: reboot Tainted: P           ----------------   2.6.32
> #1 empty
> RIP: 0010:[<ffffffff81305c2b>]  [<ffffffff81305c2b>] free_msi_irqs
> +0x11b/0x130
> RSP: 0018:ffff880185c9bc88  EFLAGS: 00010282
> RAX: ffff880219f58bc0 RBX: ffff88021ac53b00 RCX: 0000000000000000
> RDX: 0000000000000001 RSI: 0000000000000246 RDI: 000000000000004a
> RBP: ffff880185c9bcc8 R08: 0000000000000002 R09: 0000000000000106
> R10: 0000000000000000 R11: 0000000000000006 R12: ffff88021e524778
> R13: 0000000000000001 R14: ffff88021e524000 R15: 0000000000000000
> FS:  00007f90821b7700(0000) GS:ffff880028220000(0000)
> knlGS:0000000000000000
> CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
> CR2: 00007f90818bd010 CR3: 0000000132c64000 CR4: 00000000000006e0
> DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
> DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
> Process reboot (pid: 5910, threadinfo ffff880185c9a000, task
> ffff88021bf04a80)
> Stack:
>  ffff880185c9bc98 000000018130529d ffff880185c9bcc8 ffff88021e524000
> <0> 0000000000000004 ffff88021948c700 0000000000000000
> ffff880185c9bda7
> <0> ffff880185c9bce8 ffffffff81305cbd ffff880185c9bce8
> ffff88021948c700
> Call Trace:
>  [<ffffffff81305cbd>] pci_disable_msix+0x3d/0x50
>  [<ffffffffa00501d5>] ixgbe_reset_interrupt_capability+0x65/0x90
> [ixgbe]
>  [<ffffffffa00512f6>] ixgbe_clear_interrupt_scheme+0xb6/0xd0 [ixgbe]
>  [<ffffffffa005330b>] __ixgbe_shutdown+0x5b/0x200 [ixgbe]
>  [<ffffffffa00534ca>] ixgbe_shutdown+0x1a/0x60 [ixgbe]
>  [<ffffffff812f6c7c>] pci_device_shutdown+0x2c/0x50
>  [<ffffffff813727fb>] device_shutdown+0x4b/0x160
>  [<ffffffff8107d98c>] kernel_restart_prepare+0x2c/0x40
>  ehci timer_action, mod_timer io_watchdog
>  [<ffffffff8107d9e6>] kernel_restart+0x16/0x60
>  [<ffffffff8107dbfd>] sys_reboot+0x1ad/0x200
>  [<ffffffff811676cf>] ? __d_free+0x3f/0x60
>  [<ffffffff81167748>] ? d_free+0x58/0x60
>  [<ffffffff8116f7c0>] ? mntput_no_expire+0x30/0x100
>  [<ffffffff81152b11>] ? __fput+0x191/0x200
>  [<ffffffff816565fe>] ? do_page_fault+0x3e/0xa0
>  [<ffffffff8100b132>] system_call_fastpath+0x16/0x1b
> Code: 4c 89 ef e8 98 8c e3 ff 4d 39 f4 48 8b 43 10 75 cf 48 83 c4 18
> 5b 41 5c
> 41 5d 41 5e 41 5f c9 c3 49 8b 7d 20 e8 07 5a d3 ff eb c9 <0f> 0b 0f 1f
> 00 eb fb
> 66 66 66 66 66 2e 0f 1f 84 00 00 00 00 00=20
>  ehci timer_action, mod_timer io_watchdog
> RIP  [<ffffffff81305c2b>] free_msi_irqs+0x11b/0x130
>  RSP <ffff880185c9bc88>
> ---[ end trace 27de882a0fe75593 ]---
>=20
> (This was seen on a pretty old kernel/driver, but looks like=20
> the same bug is still possible.)
>=20
> Signed-off-by: <akepner@riverbed.com>=20

Thanks, I have added the patch to my ixgbe queue of patches.

--=-x/NBjTsfcYm8diPSEtAx
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.13 (GNU/Linux)

iQIcBAABCgAGBQJRQB3IAAoJEOVv75VaS+3OqJ4P/jCMihTi0NtFm0oie6aY3AM6
XPFqxsvkezmOU+nH1rlD9bRR17eRQ/OYfphd/rXgWBGfmfBv7JmfX2WNQRPMOaOO
29aBdMn+oEgUR0c0Hf868cmfi9Bn7n08mklEQV8tXbQAKm1ErqntCakuSYHjf4BM
DAa/lCOoPYgNQik7jHmXb4i+oEmi4spF3mo42og2ZVoYNzNeZNAY/M04TSQtJ9vY
gL70Ds/YqFN7Q44cN3x0owVqjjovRkgQjCYf+QaTGvpa1tZnvhPJiyQDkWUe39iw
J8+LEBldBCtB4FInpdu6DSj4J19rz87pPS65s/dQjamPrt749ew/SKEhEt6HAcnp
+E0pirY4BttVJkzLnTpnaGsjBxQiubg99qf3kTHUqJCM4RaTCnNACu9VKjiI1HIs
qy9sQsuIr37rxa1tU8nP1ao3YHxRcZ1g1BT+one7Z8L5M6j4ir5ak8hYbdJeUyqG
3zuJGeEKmRyiKa6B5KskX1wgZd7q6/3BYHvg+VlySH1npLPhjPvy6WoyLnML7WnK
oG59vbPEXV78eEJrKE0EqQcZ8T1GA8tenxXYrEG3bG3F8QIfRHhN9CGHlR4yEIsi
s43mXvH+VOsMpErmwczDWKuffbh5ROLpOIhr283kngn/UxmqgadhNfPtyrSWDVx6
BTSjANbBEX2a+a7wCjsX
=YN7J
-----END PGP SIGNATURE-----

--=-x/NBjTsfcYm8diPSEtAx--
