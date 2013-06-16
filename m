From: Sebastian Andrzej Siewior <sebastian@breakpoint.cc>
Subject: Re: [RFC/BUG] ipv6: bug in "ipv6: Copy cork options in
 ip6_append_data"
Date: Sun, 16 Jun 2013 21:07:21 +0200
Message-ID: <20130616190721.GA1515@breakpoint.cc>
References: <1368742990.3301.67.camel@edumazet-glaptop>
 <20130615185131.GA2148@breakpoint.cc>
 <1371373953.3252.162.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	netdev <netdev@vger.kernel.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Neal Cardwell <ncardwell@google.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([80.244.247.6]:49321 "EHLO
	Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755403Ab3FPTH3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 16 Jun 2013 15:07:29 -0400
Content-Disposition: inline
In-Reply-To: <1371373953.3252.162.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Jun 16, 2013 at 02:12:33AM -0700, Eric Dumazet wrote:
> 
> Yep, this was discussed 2 months ago. Initial report from Dave Jones
> 
> http://comments.gmane.org/gmane.linux.network/264030
> 
> So far, I am not sure we solved the problem.
> Could you try latest net-next tree ?

Yep. So I run pretty soon into

| BUG: unable to handle kernel paging request at 000000000e180200
| IP: [<ffffffff8131ff8c>] ip6_push_pending_frames+0x28a/0x428
| PGD 7a30f067 PUD 7a310067 PMD 0
| Oops: 0000 [#1] SMP
| Modules linked in: xfrm_user xfrm_algo ipt_ULOG x_tables can_bcm can irda crc_ccitt ax25 nfc rfkill ipx p8023 p8022 atm appletalk psnap llc nfnetlink cirrus ttm snd_pcm snd_page_alloc snd_timer snd soundcore parport_pc drm_kms_helper drm i2c_piix4 syscopyarea sysfillrect psmouse serio_raw sysimgblt parport processor button thermal_sys joydev evdev pcspkr i2c_core loop autofs4 hid_generic usbhid hid btrfs xor zlib_deflate raid6_pq crc32c libcrc32c sg sr_mod cdrom ata_generic virtio_blk virtio_net floppy ata_piix uhci_hcd ehci_hcd libata usbcore scsi_mod usb_common virtio_pci virtio_ring virtio
| CPU: 0 PID: 1034 Comm: trinity-child0 Not tainted 3.10.0-rc4-next-20130607 #1
| Hardware name: Bochs Bochs, BIOS Bochs 01/01/2007
| task: ffff880072e477f0 ti: ffff88007a31e000 task.ti: ffff88007a31e000
| RIP: 0010:[<ffffffff8131ff8c>]  [<ffffffff8131ff8c>] ip6_push_pending_frames+0x28a/0x428
| RSP: 0018:ffff88007a31fa40  EFLAGS: 00010206
| RAX: 000000000e180000 RBX: ffff88002ec6a880 RCX: ffff880061604c18
| RDX: 0f02000affff0000 RSI: 0000000000000028 RDI: ffff88007a374c80
| RBP: ffff88007a31fac0 R08: 0000000013fc42a0 R09: ffff880061604c48
| R10: 0000000000000000 R11: 0000000000000000 R12: ffff88007b599180
| R13: ffffffff81676340 R14: 0000000000000000 R15: ffff880061604cc8
| FS:  00007f68082a3700(0000) GS:ffff88007fc00000(0000) knlGS:0000000000000000
| CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
| CR2: 000000000e180200 CR3: 000000007a30e000 CR4: 00000000000006f0
| DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
| DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
| Stack:
|  ffff88007a374c00 ffff88007b599290 ffff88007b5994e0 ffff88007a374c00
|  1100000000000000 ffff88007a31fa70 0000000000000000 0f02000affff0000
|  0000000000000000 000000000a49eee4 0000000000000000 ffff88007b599180
| Call Trace:
|  [<ffffffff81332a98>] ? udp_v6_push_pending_frames+0x25d/0x2d5
|  [<ffffffff813338f2>] ? udpv6_sendmsg+0x6db/0x8a0
|  [<ffffffff810b75c9>] ? get_page_from_freelist+0x5df/0x69f
|  [<ffffffff8129cc4e>] ? sock_sendmsg+0x54/0x70
|  [<ffffffff810f1048>] ? fatal_signal_pending+0x9/0x23
|  [<ffffffff812a637d>] ? verify_iovec+0x53/0xa0
|  [<ffffffff8129ce9f>] ? ___sys_sendmsg+0x1fe/0x28e
|  [<ffffffff810d0776>] ? handle_mm_fault+0x1ae/0x20b
|  [<ffffffff81064b23>] ? timekeeping_get_ns.constprop.10+0xd/0x31
|  [<ffffffff811b571d>] ? timerqueue_add+0x75/0x8f
|  [<ffffffff8104b6b9>] ? lock_hrtimer_base.isra.14+0x1b/0x3c
|  [<ffffffff8129db2f>] ? __sys_sendmsg+0x39/0x57
|  [<ffffffff813719d2>] ? system_call_fastpath+0x16/0x1b
| Code: 48 8b 44 24 18 48 85 c0 74 0c 48 8d b8 80 00 00 00 e8 e0 e2 ff ff 48 8b 44 24 18 48 89 43 58 48 8b 80 48 01 00 00 48 85 c0 74 14 <48> 8b 80 00 02 00 00 65 48 ff 40 28 8b 53 68 65 48 01 50 30 49
| RIP  [<ffffffff8131ff8c>] ip6_push_pending_frames+0x28a/0x428
|  RSP <ffff88007a31fa40>
| CR2: 000000000e180200
| ---[ end trace 9177219b59c3a20e ]---

I think this is different :) I will see if I can trigger the other issue.

Sebastian
