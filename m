From: Michal Piotrowski <michal.k.k.piotrowski@gmail.com>
Subject: kernel BUG at include/net/tcp.h:739
Date: Wed, 02 May 2007 22:15:10 +0200
Message-ID: <4638F14E.6000803@googlemail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-2
Content-Transfer-Encoding: 7bit
To: =?ISO-8859-2?Q?Ilpo_J=E4rvinen?= <ilpo.jarvinen@helsinki.fi>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	LKML <linux-kernel@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ug-out-1314.google.com ([66.249.92.173]:49608 "EHLO
	ug-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1766909AbXEBUPY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 May 2007 16:15:24 -0400
Received: by ug-out-1314.google.com with SMTP id 44so323610uga
        for <netdev@vger.kernel.org>; Wed, 02 May 2007 13:15:23 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Ilpo,

Please take a look at this bug

[15236.638092] kernel BUG at /mnt/md0/devel/linux-git/include/net/tcp.h:739!
[15236.644860] invalid opcode: 0000 [#1]
[15236.648514] PREEMPT SMP 
[15236.651075] Modules linked in: ipt_MASQUERADE iptable_nat nf_nat autofs4 af_packet nf_conntrack_netbios_ns ipt_REJECT nf_conntrack_ipv4 xt_state nf_conntrack nfnetlink iptable_filter ip_tables ip6t_REJECT xt_tcpudp ip6table_filter ip6_tables x_tables ipv6 binfmt_misc thermal processor fan container nvram snd_intel8x0 snd_ac97_codec ac97_bus snd_seq_dummy snd_seq_oss snd_seq_midi_event snd_seq snd_seq_device snd_pcm_oss snd_mixer_oss snd_pcm evdev snd_timer snd intel_agp i2c_i801 soundcore agpgart snd_page_alloc ide_cd cdrom rtc unix
[15236.698898] CPU:    0
[15236.698899] EIP:    0060:[<c02f798b>]    Not tainted VLI
[15236.698900] EFLAGS: 00010206   (2.6.21-gdc87c398 #169)
[15236.711580] EIP is at tcp_ack+0xc54/0x16a0
[15236.715664] eax: 00000017   ebx: 00000000   ecx: 00000003   edx: 0000010e
[15236.722433] esi: d5bc1254   edi: 0000010e   ebp: c0462e18   esp: c0462da8
[15236.729202] ds: 007b   es: 007b   fs: 00d8  gs: 0000  ss: 0068
[15236.735019] Process swapper (pid: 0, ti=c0462000 task=c03f14e0 task.ti=c0427000)
[15236.742219] Stack: 00000000 00000000 00000000 00000198 00000100 00000000 00000000 00000018 
[15236.750698]        3b4d5775 0ffef1c0 3b4d79ad 00000001 00000018 00000006 3b4d79ad 003f14e0 
[15236.759178]        00000006 0000082a d4b9cde0 00e4059a 0000000c 00000000 00000000 0130204a 
[15236.767649] Call Trace:
[15236.770286]  [<c0105039>] show_trace_log_lvl+0x1a/0x2f
[15236.775438]  [<c01050eb>] show_stack_log_lvl+0x9d/0xa5
[15236.780590]  [<c01052e0>] show_registers+0x1ed/0x32c
[15236.785569]  [<c0105537>] die+0x118/0x22f
[15236.789588]  [<c01056c7>] do_trap+0x79/0x91
[15236.793781]  [<c0105f57>] do_invalid_op+0x97/0xa1
[15236.798501]  [<c031f38c>] error_code+0x7c/0x84
[15236.802960]  [<c02fafb7>] tcp_rcv_established+0x568/0x645
[15236.808354]  [<c03000bd>] tcp_v4_do_rcv+0x2b/0x32c
[15236.813144]  [<c030243a>] tcp_v4_rcv+0x7f9/0x86b
[15236.817777]  [<c02e9dd3>] ip_local_deliver+0x170/0x235
[15236.822928]  [<c02e9c2a>] ip_rcv+0x4f3/0x52c
[15236.827199]  [<c02d4909>] netif_receive_skb+0x1b9/0x252
[15236.832437]  [<c02635c2>] skge_poll+0x47a/0x545
[15236.836967]  [<c02d68df>] net_rx_action+0x9f/0x192
[15236.841772]  [<c0126408>] __do_softirq+0x6d/0xea
[15236.846407]  [<c01069b5>] do_softirq+0x64/0xd1
[15236.850867]  =======================
[15236.854437] Code: 69 42 c0 f7 d0 64 8b 15 04 00 00 00 8b 04 90 ff 80 a4 00 00 00 8b 9e 70 05 00 00 89 d8 03 86 74 05 00 00 3b 86 8c 04 00 00 76 04 <0f> 0b eb fe 89 86 90 04 00 00 8a 86 88 03 00 00 84 c0 75 3c 83 
[15236.874343] EIP: [<c02f798b>] tcp_ack+0xc54/0x16a0 SS:ESP 0068:c0462da8

l *0xc02f798b
0xc02f798b is in tcp_ack (/mnt/md0/devel/linux-git/include/net/tcp.h:739).
734                                 (tp->snd_cwnd >> 2)));
735     }
736
737     static inline void tcp_sync_left_out(struct tcp_sock *tp)
738     {
739             BUG_ON(tp->sacked_out + tp->lost_out > tp->packets_out);
740             tp->left_out = tp->sacked_out + tp->lost_out;
741     }
742
743     extern void tcp_enter_cwr(struct sock *sk, const int set_ssthresh);

Caused by commit 34588b4c046c34773e5a1a962da7b78b05c4d1bd 

http://www.stardust.webpages.pl/files/tbf/bitis-gabonica/2.6.21-git4/serial-console.log
http://www.stardust.webpages.pl/files/tbf/bitis-gabonica/2.6.21-git4/git-config

Regards,
Michal

-- 
Michal K. K. Piotrowski
Kernel Monkeys
(http://kernel.wikidot.com/start)
