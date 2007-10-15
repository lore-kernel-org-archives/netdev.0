From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: Re: kernel BUG at net/core/dev.c:1383 skb_checksum_help: BUG_ON(offset
 > (int)skb->len)
Date: Mon, 15 Oct 2007 13:08:20 +0300 (EEST)
Message-ID: <Pine.LNX.4.64.0710151251090.3767@kivilampi-30.cs.helsinki.fi>
References: <20071006141506.785a6683@localhost.localdomain>
 <20071014192640.35065e73@inria.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Netdev <netdev@vger.kernel.org>
To: Guillaume Chazarain <guichaz@yahoo.fr>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:57447 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756160AbXJOKIX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Oct 2007 06:08:23 -0400
In-Reply-To: <20071014192640.35065e73@inria.fr>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, 14 Oct 2007, Guillaume Chazarain wrote:

> > #0  skb_checksum_help (skb=0xc73c8cb0) at net/core/dev.c:1383
> > 1383            BUG_ON(offset > (int)skb->len);
> 
> This same crash
> (http://marc.info/?l=linux-netdev&m=119167366621392&w=2) happened
> again, this time with a recent git
> (d773b33972a663cfaf066e966f87922a74088a1e), here are some gdb info. I
> have the complete kdump image but I still lack a reliable way to
> reproduce the problem.
> 
> <2>kernel BUG at net/core/dev.c:1372!
> <0>invalid opcode: 0000 [#1]
> <0>PREEMPT 
> <4>Modules linked in: michael_mic arc4 ecb blkcipher ieee80211_crypt_tkip radeon drm acpi_cpufreq kqemu lm90 hwmon ipv6 binfmt_misc dm_mirror dm_mod snd_intel8x0m snd_seq_dummy snd_intel8x0 snd_ac97_codec ac97_bus snd_seq_oss snd_seq_midi_event snd_seq snd_seq_device snd_pcm_oss snd_mixer_oss snd_pcm ohci1394 ieee1394 snd_timer sr_mod snd soundcore hci_usb firewire_ohci i2c_i801 sdhci mmc_core bluetooth snd_page_alloc serio_raw cdrom i2c_core firewire_core crc_itu_t usbhid hid rtc_cmos pcspkr button video irda rtc_core rtc_lib ipw2200 ieee80211 iTCO_wdt skge output battery ac asus_laptop led_class crc_ccitt ieee80211_crypt sg pata_acpi ehci_hcd ohci_hcd uhci_hcd
> <0>CPU:    0
> <0>EIP:    0060:[<c02c9d5e>]    Not tainted VLI
> <0>EFLAGS: 00010202   (2.6.23-taskstats #31)
> <0>EIP is at skb_checksum_help+0x66/0xcb
> <0>eax: 000000aa   ebx: e218dcb0   ecx: 00000072   edx: 001000cc
> <0>esi: 00002822   edi: d9d848b8   ebp: c0443c58   esp: c0443c4c
> <0>ds: 007b   es: 007b   fs: 0000  gs: 0000  ss: 0068
> <0>Process swapper (pid: 0, ti=c0443000 task=c03d6280 task.ti=c0404000)
> <0>Stack: 00000020 f7c80000 e218dcb0 c0443c74 c02cbf6c f5d28380 00000048 e218dcb0 
> <0>       f5de82a4 d9d848b8 c0443ca4 c02ea432 f5949400 c0443ca8 c0443d38 f2d8f028 
> <0>       0000000e f5de8280 e218dcb0 d9d848b8 f5180440 000015e0 c0443d14 c02e9ba9 
> <0>Call Trace:
> <0> [<c0107eee>] show_trace_log_lvl+0x1a/0x2f
> <0> [<c0107fa0>] show_stack_log_lvl+0x9d/0xa5
> <0> [<c0108175>] show_registers+0x1cd/0x2e3
> <0> [<c01083a8>] die+0x11d/0x218
> <0> [<c0328837>] do_trap+0x89/0xa2
> <0> [<c0108762>] do_invalid_op+0x88/0x92
> <0> [<c032860a>] error_code+0x6a/0x70
> <0> [<c02cbf6c>] dev_queue_xmit+0x11e/0x2da
> <0> [<c02ea432>] ip_output+0x239/0x273
> <0> [<c02e9ba9>] ip_queue_xmit+0x324/0x35c
> <0> [<c02f7a23>] tcp_transmit_skb+0x638/0x66b
> <0> [<c02f8852>] tcp_retransmit_skb+0x502/0x5f5
> <0> [<c02f89f7>] tcp_xmit_retransmit_queue+0xb2/0x252
> <0> [<c02f5747>] tcp_ack+0x15ae/0x1776
> <0> [<c02f6ba3>] tcp_rcv_established+0x521/0x5f2
> <0> [<c02fbc65>] tcp_v4_do_rcv+0x2b/0x31d
> <0> [<c02fdf58>] tcp_v4_rcv+0x858/0x8cc
> <0> [<c02e5a50>] ip_local_deliver+0x193/0x22b
> <0> [<c02e5890>] ip_rcv+0x478/0x4a5
> <0> [<c02c96b6>] netif_receive_skb+0x359/0x3da
> <0> [<c02cb523>] process_backlog+0x6d/0xc5
> <0> [<c02cb1b1>] net_rx_action+0x8b/0x16b
> <0> [<c0123a20>] __do_softirq+0x41/0x8c
> <0> [<c0108d63>] do_softirq+0x5e/0xb9
> <0> =======================
> <0>Code: 89 d8 c7 04 24 20 00 00 00 e8 57 ad ff ff 85 c0 75 79 0f b7 73 5c 8b 83 a4 00 00 00 2b 83 a0 00 00 00 8b 4b 50 29 c6 39 ce 7e 04 <0f> 0b eb fe 29 f1 89 f2 89 d8 c7 04 24 00 00 00 00 e8 e0 9e ff 
> <0>EIP: [<c02c9d5e>] skb_checksum_help+0x66/0xcb SS:ESP 0068:c0443c4c
> 
> 
> #0  0xc02c9d5e in skb_checksum_help (skb=0xe218dcb0) at net/core/dev.c:1372
> 1372            BUG_ON(offset > (int)skb->len);
> (gdb) bt full
> #0  0xc02c9d5e in skb_checksum_help (skb=0xe218dcb0) at net/core/dev.c:1372
>         csum = 1048780
>         ret = <value optimized out>
>         offset = 10274
> #1  0xc02cbf6c in dev_queue_xmit (skb=0xe218dcb0) at net/core/dev.c:1631
>         dev = (struct net_device *) 0xf7c80000
>         q = <value optimized out>
>         rc = <value optimized out>
> #2  0xc02ea432 in ip_output (skb=0xe218dcb0) at include/net/neighbour.h:319
>         __ret = <value optimized out>
>         dev = <value optimized out>
> #3  0xc02e9ba9 in ip_queue_xmit (skb=0xe218dcb0, ipfragok=0)
>     at include/net/dst.h:232
>         __ret = <value optimized out>
>         sk = (struct sock *) 0xf5180440
>         opt = (struct ip_options *) 0x0
>         rt = (struct rtable *) 0xed3db300
>         iph = (struct iphdr *) 0xd9d848b8
> #4  0xc02f7a23 in tcp_transmit_skb (sk=0xf5180440, skb=0xe218dcb0, 
>     clone_it=<value optimized out>, gfp_mask=32) at net/ipv4/tcp_output.c:609
>         tp = <value optimized out>
>         tcb = (struct tcp_skb_cb *) 0xe218dcd0
>         tcp_header_size = 60
>         th = <value optimized out>
>         sysctl_flags = 0
>         err = <value optimized out>
> #5  0xc02f8852 in tcp_retransmit_skb (sk=0xf5180440, skb=0xe218dc00)
>     at net/ipv4/tcp_output.c:1903
>         tp = <value optimized out>
>         cur_mss = <value optimized out>
>         err = -113
> #6  0xc02f89f7 in tcp_xmit_retransmit_queue (sk=0xf5180440)
>     at net/ipv4/tcp_output.c:1982
>         sacked = <value optimized out>
>         skb = <value optimized out>
>         packet_cnt = 0
> #7  0xc02f5747 in tcp_ack (sk=0xf5180440, skb=0xd3606b40, flag=1294)
>     at net/ipv4/tcp_input.c:2508
>         packets_acked = 1
>         sacked = 132 '\204'
>         tp = <value optimized out>
>         prior_snd_una = 4014267677
>         ack_seq = 3213368850
>         ack = 4014269059
>         prior_in_flight = 4111991984

This one doesn't look very sane number... But it may well be ok due to 
some compiler trick (dunno)... Just for completeness, could you print 
tcp_sock contents too so I could briefly have a look (though I suspect 
that the problem is elsewhere), thanks...

>         seq_rtt = -1
>         frto_cwnd = <value optimized out>
> #8  0xc02f6ba3 in tcp_rcv_established (sk=0xf5180440, skb=0xd3606b40, 

...snip...


-- 
 i.
