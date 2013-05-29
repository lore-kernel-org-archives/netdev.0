From: Matthias Schiffer <mschiffer@universe-factory.net>
Subject: Kernel panic in IPv6 ndisc/redirect in kernel 3.9.4
Date: Wed, 29 May 2013 23:02:43 +0200
Message-ID: <51A66CF3.7010202@universe-factory.net>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="----enig2LMLMCLVKTLJTVBLRQOXH"
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: davem@davemloft.net, kuznet@ms2.inr.ac.ru, jmorris@namei.org,
	yoshfuji@linux-ipv6.org, kaber@trash.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from chaos.universe-factory.net ([5.9.180.86]:55744 "EHLO
	chaos.universe-factory.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S966994Ab3E2VMW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 May 2013 17:12:22 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
------enig2LMLMCLVKTLJTVBLRQOXH
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

Hi,
we've hit the following panic several times in the last days on some of
our servers running kernel 3.9.4. Is seems to be a regression in the 3.9
series, as we never hit it with 3.8.x or earlier.

Please let me know if there is anything more I can do to help fix this;
I probably won't have time to try to reproduce this on a test machine
and/or bisect it till weekend.


[25743.461449] skbuff: skb_over_panic: text:ffffffff814866d8 len:608
put:8 head:ffff88001d643400 data:ffff88001d643466 tail:0x2c6 end:0x2c0
dev:freifunk-hl
[25743.471582] ------------[ cut here ]------------
[25743.473301] kernel BUG at net/core/skbuff.c:126!
[25743.474113] invalid opcode: 0000 [#1] PREEMPT SMP
[25743.474113] Modules linked in: sit tunnel4 bridge stp llc tun
ipt_MASQUERADE iptable_nat nf_conntrack_ipv4 nf_defrag_ipv4 nf_nat_ipv4
nf_nat nf_conntrack ip6t_NPT iptable_mangle iptable_filter xt_mark
ip6table_mangle ip_tables ip6_tables x_tables kvm_amd kvm psmouse evdev
serio_raw pcspkr i2c_piix4 intel_agp processor i2c_core button intel_gtt
batman_adv crc32c libcrc32c ext4 crc16 mbcache jbd2 ata_generic
pata_acpi uhci_hcd ata_piix usbcore usb_common libata scsi_mod floppy
virtio_balloon virtio_net virtio_pci virtio_blk virtio_ring virtio
[25743.474113] CPU 0
[25743.474113] Pid: 317, comm: fastd Not tainted 3.9.4-1-ARCH #1 Bochs Bo=
chs
[25743.474113] RIP: 0010:[<ffffffff814ce613>]  [<ffffffff814ce613>]
skb_panic+0x63/0x65
[25743.474113] RSP: 0018:ffff88001fc03998  EFLAGS: 00010282
[25743.474113] RAX: 000000000000008c RBX: 0000000000000008 RCX:
ffff88001fc0fed0
[25743.474113] RDX: 0000000000000000 RSI: ffff88001fc0dfc8 RDI:
0000000000000246
[25743.474113] RBP: ffff88001fc039b8 R08: ffffffff818b4220 R09:
00000000000001eb
[25743.474113] R10: 303a646e65203663 R11: 7665642030633278 R12:
0000000000000000
[25743.474113] R13: ffff88001ccfff00 R14: 0000000000000008 R15:
0000000000000006
[25743.474113] FS:  00007fd1e10d2700(0000) GS:ffff88001fc00000(0000)
knlGS:0000000000000000
[25743.474113] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[25743.474113] CR2: 00007f777b64d838 CR3: 000000001d7fc000 CR4:
00000000000006f0
[25743.474113] DR0: 0000000000000000 DR1: 0000000000000000 DR2:
0000000000000000
[25743.474113] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7:
0000000000000400
[25743.474113] Process fastd (pid: 317, threadinfo ffff88001df30000,
task ffff88001f764300)
[25743.474113] Stack:
[25743.474113]  ffff88001d643466 00000000000002c6 00000000000002c0
ffff88001cd90000
[25743.474113]  ffff88001fc039c8 ffffffff813ca996 ffff88001fc03a10
ffffffff814866d8
[25743.474113]  0000000000000002 ffff88001fc03a68 ffff88001ccff100
ffff88001ccfff00
[25743.474113] Call Trace:
[25743.474113]  <IRQ>
[25743.474113]  [<ffffffff813ca996>] skb_put+0x46/0x50
[25743.474113]  [<ffffffff814866d8>] ndisc_fill_addr_option+0x68/0xd0
[25743.474113]  [<ffffffff814884c9>] ndisc_send_redirect+0x329/0x3d0
[25743.474113]  [<ffffffff813f1611>] ? fib_rules_lookup+0x101/0x160
[25743.474113]  [<ffffffff814724c1>] ip6_forward+0x7d1/0x820
[25743.474113]  [<ffffffff81473150>] ip6_rcv_finish+0x80/0x90
[25743.474113]  [<ffffffff81473839>] ipv6_rcv+0x289/0x400
[25743.474113]  [<ffffffff813d69ea>] __netif_receive_skb_core+0x65a/0x8b0=

[25743.474113]  [<ffffffff813d6c58>] __netif_receive_skb+0x18/0x60
[25743.474113]  [<ffffffff813d6cd3>] netif_receive_skb+0x33/0xc0
[25743.474113]  [<ffffffffa038d5a0>] br_handle_frame_finish+0x230/0x330
[bridge]
[25743.474113]  [<ffffffffa0393a67>]
br_nf_pre_routing_finish_ipv6+0xe7/0x160 [bridge]
[25743.474113]  [<ffffffffa0394ac9>] br_nf_pre_routing+0x589/0x6f0 [bridg=
e]
[25743.474113]  [<ffffffff814043ab>] nf_iterate+0x8b/0xa0
[25743.474113]  [<ffffffffa038d370>] ? br_handle_local_finish+0x60/0x60
[bridge]
[25743.474113]  [<ffffffff8140443c>] nf_hook_slow+0x7c/0x120
[25743.474113]  [<ffffffffa038d370>] ? br_handle_local_finish+0x60/0x60
[bridge]
[25743.474113]  [<ffffffffa038d870>] br_handle_frame+0x1d0/0x270 [bridge]=

[25743.474113]  [<ffffffff813d65c2>] __netif_receive_skb_core+0x232/0x8b0=

[25743.474113]  [<ffffffff813d6c58>] __netif_receive_skb+0x18/0x60
[25743.474113]  [<ffffffff813d806e>] process_backlog+0xae/0x1a0
[25743.474113]  [<ffffffff813d7ea1>] net_rx_action+0x161/0x280
[25743.474113]  [<ffffffff810606a7>] __do_softirq+0xe7/0x2a0
[25743.474113]  [<ffffffff814db31c>] call_softirq+0x1c/0x30
[25743.474113]  <EOI>
[25743.474113]  [<ffffffff810176a5>] do_softirq+0x55/0x90
[25743.474113]  [<ffffffff813d54e0>] netif_rx_ni+0x60/0x80
[25743.474113]  [<ffffffffa0379e7d>] tun_get_user+0x3fd/0x7b0 [tun]
[25743.474113]  [<ffffffffa037a329>] tun_chr_aio_write+0x79/0xb0 [tun]
[25743.474113]  [<ffffffff8118b0e0>] do_sync_write+0xa0/0xe0
[25743.474113]  [<ffffffff8118b4c2>] ? rw_verify_area+0x52/0xd0
[25743.474113]  [<ffffffff8118b74b>] vfs_write+0x9b/0x170
[25743.474113]  [<ffffffff8118ba49>] sys_write+0x49/0xa0
[25743.474113]  [<ffffffff814d9e9d>] system_call_fastpath+0x1a/0x1f
[25743.474113] Code: 00 00 48 89 44 24 10 8b 87 d4 00 00 00 48 89 44 24
08 48 8b 87 e8 00 00 00 48 c7 c7 a8 91 74 81 48 89 04 24 31 c0 e8 73 b7
ff ff <0f> 0b 66 66 66 66 90 55 48 89 e5 41 56 41 55 41 54 53 48 89 fb
[25743.474113] RIP  [<ffffffff814ce613>] skb_panic+0x63/0x65
[25743.474113]  RSP <ffff88001fc03998>
[25743.615687] ---[ end trace 49c54f3f1691b26e ]---
[25743.617203] Kernel panic - not syncing: Fatal exception in interrupt



------enig2LMLMCLVKTLJTVBLRQOXH
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.20 (GNU/Linux)
Comment: Using GnuPG with Thunderbird - http://www.enigmail.net/

iEYEARECAAYFAlGmbPMACgkQq3qIxbiQM9hH0gCdHdlF4oaH5cnTKsLJZwLLltVQ
aIUAnAgj943ovtcVoJwSkHifppv+aldM
=RUR3
-----END PGP SIGNATURE-----

------enig2LMLMCLVKTLJTVBLRQOXH--
