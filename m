From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: skbuff: skb_under_panic warning in 3.10rc7+
Date: Mon, 1 Jul 2013 00:13:22 +0200
Message-ID: <20130630221322.GA27948@order.stressinduktion.org>
References: <20130630160246.GA24539@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: netdev@vger.kernel.org
To: Dave Jones <davej@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from s15338416.onlinehome-server.info ([87.106.68.36]:46766 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751320Ab3F3WNY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 30 Jun 2013 18:13:24 -0400
Content-Disposition: inline
In-Reply-To: <20130630160246.GA24539@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Jun 30, 2013 at 12:02:46PM -0400, Dave Jones wrote:
> skbuff: skb_under_panic: text:ffffffff816765f6 len:48 put:40 head:ffff88013deb6df0 data:ffff88013deb6dec tail:0x2c end:0xc0 dev:<NULL>
> ------------[ cut here ]------------
> kernel BUG at net/core/skbuff.c:126!
> invalid opcode: 0000 [#1] PREEMPT SMP DEBUG_PAGEALLOC
> Modules linked in: dccp_ipv4 dccp 8021q garp bridge stp dlci mpoa snd_seq_dummy sctp fuse hidp tun bnep nfnetlink scsi_transport_iscsi rfcomm can_raw can_bcm af_802154 appletalk caif_socket can caif ipt_ULOG x25 rose af_key pppoe pppox ipx phonet irda llc2 ppp_generic slhc p8023 psnap p8022 llc crc_ccitt atm bluetooth netrom ax25 nfc rfkill rds af_rxrpc coretemp hwmon kvm_intel kvm crc32c_intel snd_hda_codec_realtek ghash_clmulni_intel microcode pcspkr snd_hda_codec_hdmi snd_hda_intel snd_hda_codec snd_hwdep usb_debug snd_seq snd_seq_device snd_pcm e1000e snd_page_alloc snd_timer ptp snd pps_core soundcore xfs libcrc32c
> CPU: 2 PID: 8095 Comm: trinity-child2 Not tainted 3.10.0-rc7+ #37 
> task: ffff8801f52c2520 ti: ffff8801e6430000 task.ti: ffff8801e6430000
> RIP: 0010:[<ffffffff816e759c>]  [<ffffffff816e759c>] skb_panic+0x63/0x65
> RSP: 0018:ffff8801e6431de8  EFLAGS: 00010282
> RAX: 0000000000000086 RBX: ffff8802353d3cc0 RCX: 0000000000000006
> RDX: 0000000000003b90 RSI: ffff8801f52c2ca0 RDI: ffff8801f52c2520
> RBP: ffff8801e6431e08 R08: 0000000000000000 R09: 0000000000000000
> R10: 0000000000000001 R11: 0000000000000001 R12: ffff88022ea0c800
> R13: ffff88022ea0cdf8 R14: ffff8802353ecb40 R15: ffffffff81cc7800
> FS:  00007f5720a10740(0000) GS:ffff880244c00000(0000) knlGS:0000000000000000
> CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
> CR2: 0000000005862000 CR3: 000000022843c000 CR4: 00000000001407e0
> DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
> DR3: 0000000000000000 DR6: 00000000fffe0ff0 DR7: 0000000000000600
> Stack:
>  ffff88013deb6dec 000000000000002c 00000000000000c0 ffffffff81a3f6e4
>  ffff8801e6431e18 ffffffff8159a9aa ffff8801e6431e90 ffffffff816765f6
>  ffffffff810b756b 0000000700000002 ffff8801e6431e40 0000fea9292aa8c0
> Call Trace:
>  [<ffffffff8159a9aa>] skb_push+0x3a/0x40
>  [<ffffffff816765f6>] ip6_push_pending_frames+0x1f6/0x4d0
>  [<ffffffff810b756b>] ? mark_held_locks+0xbb/0x140
>  [<ffffffff81694919>] udp_v6_push_pending_frames+0x2b9/0x3d0
>  [<ffffffff81694660>] ? udplite_getfrag+0x20/0x20
>  [<ffffffff8162092a>] udp_lib_setsockopt+0x1aa/0x1f0
>  [<ffffffff811cc5e7>] ? fget_light+0x387/0x4f0
>  [<ffffffff816958a4>] udpv6_setsockopt+0x34/0x40
>  [<ffffffff815949f4>] sock_common_setsockopt+0x14/0x20
>  [<ffffffff81593c31>] SyS_setsockopt+0x71/0xd0
>  [<ffffffff816f5d54>] tracesys+0xdd/0xe2
> Code: 00 00 48 89 44 24 10 8b 87 d8 00 00 00 48 89 44 24 08 48 8b 87 e8 00 00 00 48 c7 c7 c0 04 aa 81 48 89 04 24 31 c0 e8 e1 7e ff ff <0f> 0b 55 48 89 e5 0f 0b 55 48 89 e5 0f 0b 55 48 89 e5 0f 0b 55 
> RIP  [<ffffffff816e759c>] skb_panic+0x63/0x65
>  RSP <ffff8801e6431de8>

Dave, could you try to reproduce this Eric's patch

https://git.kernel.org/cgit/linux/kernel/git/davem/net-next.git/commit/net/ipv6/ip6_output.c?id=284041ef21fdf2e0d216ab6b787bc9072b4eb58a

cherry-picked from net-next? I could just test net-next with my testcase and
at least my BUG does not occur any more.

Thanks,

  Hannes
