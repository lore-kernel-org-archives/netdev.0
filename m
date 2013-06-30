From: Dave Jones <davej@redhat.com>
Subject: Re: appletalk induced soft lockup
Date: Sun, 30 Jun 2013 19:47:47 -0400
Message-ID: <20130630234747.GC4325@redhat.com>
References: <20130630234252.GB4325@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: acme@ghostprotocols.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:42531 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751400Ab3F3Xr5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 30 Jun 2013 19:47:57 -0400
Content-Disposition: inline
In-Reply-To: <20130630234252.GB4325@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Jun 30, 2013 at 07:42:52PM -0400, Dave Jones wrote:
 > is atalk even maintained any more ? If not I'll take it out of my testing.
 > Arnaldo is listed as its maintainer, but I'm sure he has more interesting things
 > to work on these days :)
 > 
 > 	Dave
 > 
 > BUG: soft lockup - CPU#0 stuck for 22s! [trinity-child1:28929]
 > Modules linked in: dlci bridge stp fuse tun snd_seq_dummy hidp rfcomm bnep ipt_ULOG scsi_transport_iscsi can_raw af_802154 nfnetlink netrom appletalk ipx p8023 psnap p8022 x25 af_rxrpc can_bcm phonet can caif_socket caif l
 > lc2 rose llc irda crc_ccitt ax25 af_key atm pppoe pppox ppp_generic slhc rds bluetooth nfc rfkill snd_hda_codec_realtek coretemp hwmon kvm_intel kvm snd_hda_codec_hdmi crc32c_intel ghash_clmulni_intel microcode usb_debug snd_seq snd_hda_
 > intel snd_seq_device pcspkr snd_hda_codec e1000e snd_hwdep ptp snd_pcm pps_core snd_page_alloc snd_timer snd soundcore xfs libcrc32c
 > irq event stamp: 2975873
 > hardirqs last  enabled at (2975872): [<ffffffff816edca0>] restore_args+0x0/0x30
 > hardirqs last disabled at (2975873): [<ffffffff816f67aa>] apic_timer_interrupt+0x6a/0x80
 > softirqs last  enabled at (1374414): [<ffffffff810542e4>] __do_softirq+0x194/0x440
 > softirqs last disabled at (1374867): [<ffffffff8105474d>] irq_exit+0xcd/0xe0
 > CPU: 0 PID: 28929 Comm: trinity-child1 Not tainted 3.10.0-rc7+ #37
 > task: ffff8801c142ca40 ti: ffff8802280a8000 task.ti: ffff8802280a8000
 > RIP: 0010:[<ffffffff816ed077>]  [<ffffffff816ed077>] _raw_spin_unlock_irqrestore+0x67/0x80
 > RSP: 0018:ffff880244803df0  EFLAGS: 00000282
 > RAX: ffff8801c142ca40 RBX: ffffffff816edca0 RCX: 0000000000000002
 > RDX: 00000000000022c0 RSI: ffff8801c142d1f8 RDI: ffff8801c142ca40
 > RBP: ffff880244803e00 R08: 0000000000000000 R09: 0000000000000000
 > R10: 0000000000000001 R11: 0000000000000001 R12: ffff880244803d68
 > R13: ffffffff816f67af R14: ffff880244803e00 R15: ffffffff81cc4500
 > FS:  00007fbf71087740(0000) GS:ffff880244800000(0000) knlGS:0000000000000000
 > CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
 > CR2: 0000003e12810414 CR3: 00000001c166a000 CR4: 00000000001407f0
 > DR0: 00000000021d17e0 DR1: 0000000000000000 DR2: 0000000000000000
 > DR3: 0000000000000000 DR6: 00000000fffe0ff0 DR7: 0000000000000600
 > Stack:
 >  0000000000000282 ffffffff81cc4560 ffff880244803e18 ffffffff8158562d
 >  ffffffff820ff240 ffff880244803e88 ffffffff8105ca7a ffffffff8105c9f5
 >  ffffffff82d06d5d ffffffff825108b0 0000000000000000 ffffffff81a6b8f1
 > Call Trace:
 >  <IRQ> 
 >  [<ffffffff8158562d>] flush_unmaps_timeout+0x2d/0x30
 >  [<ffffffff8105ca7a>] call_timer_fn+0x8a/0x370
 >  [<ffffffff8105c9f5>] ? call_timer_fn+0x5/0x370
 >  [<ffffffff81585600>] ? flush_unmaps+0x170/0x170
 >  [<ffffffff8105cf9c>] run_timer_softirq+0x23c/0x390
 >  [<ffffffff8105424f>] __do_softirq+0xff/0x440
 >  [<ffffffff8105474d>] irq_exit+0xcd/0xe0
 >  [<ffffffff816f764b>] smp_apic_timer_interrupt+0x6b/0x9b
 >  [<ffffffff81596743>] ? release_sock+0x193/0x1f0
 >  [<ffffffff816f67af>] apic_timer_interrupt+0x6f/0x80
 >  <EOI> 
 >  [<ffffffff816edca0>] ? retint_restore_args+0xe/0xe
 >  [<ffffffff81052eb2>] ? local_bh_enable_ip+0x82/0xf0
 >  [<ffffffff816ed00a>] _raw_spin_unlock_bh+0x3a/0x40
 >  [<ffffffff81596743>] release_sock+0x193/0x1f0
 >  [<ffffffffa04b6331>] atalk_sendmsg+0x91/0x640 [appletalk]
 >  [<ffffffff811de020>] ? splice_from_pipe_feed+0x140/0x140
 >  [<ffffffff81592529>] sock_sendmsg+0x99/0xd0
 >  [<ffffffff81091e4f>] ? local_clock+0x3f/0x50
 >  [<ffffffff81091e4f>] ? local_clock+0x3f/0x50
 >  [<ffffffff81592597>] kernel_sendmsg+0x37/0x50
 >  [<ffffffff81594e2a>] sock_no_sendpage+0x8a/0xa0
 >  [<ffffffff8159162b>] kernel_sendpage+0x1b/0x30
 >  [<ffffffff8159166a>] sock_sendpage+0x2a/0x30
 >  [<ffffffff811de088>] pipe_to_sendpage+0x68/0x80

incomplete paste..

 [<ffffffff811de088>] pipe_to_sendpage+0x68/0x80
 [<ffffffff811ddf64>] splice_from_pipe_feed+0x84/0x140
 [<ffffffff811de020>] ? splice_from_pipe_feed+0x140/0x140
 [<ffffffff811de30e>] __splice_from_pipe+0x6e/0x90
 [<ffffffff811de020>] ? splice_from_pipe_feed+0x140/0x140
 [<ffffffff811dff41>] splice_from_pipe+0x51/0x70
 [<ffffffff811dff60>] ? splice_from_pipe+0x70/0x70
 [<ffffffff811dff75>] generic_splice_sendpage+0x15/0x20
 [<ffffffff811de9f7>] do_splice_from+0x97/0x110
 [<ffffffff811e097c>] SyS_splice+0x62c/0x6e0
 [<ffffffff816f5d54>] tracesys+0xdd/0xe2
Code: 00 e8 9e 47 00 00 65 48 8b 04 25 f0 b9 00 00 48 8b 80 38 e0 ff ff a8 08 75 13 5b 41 5c 5d c3 0f 1f 44 00 00 e8 5b a7 9c ff 53 9d <eb> cf 0f 1f 80 00 00 00 00 e8 bb ea ff ff eb df 66 0f 1f 84 00 
