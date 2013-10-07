From: dormando <dormando@rydia.net>
Subject: Re: IPv6 kernel warning
Date: Mon, 7 Oct 2013 12:56:45 -0700 (PDT)
Message-ID: <alpine.DEB.2.02.1310071256190.17658@dtop>
References: <20130920131153.GF12758@n2100.arm.linux.org.uk> <20130920160830.GA4241@marquez.int.rhx> <CAK6E8=eNFG0fic+NYeQBjEoUQMeZKSAT3LU0JSQyE-4i_cDaZQ@mail.gmail.com> <alpine.DEB.2.02.1310071111240.17658@dtop>
 <CAK6E8=czoej81t=-J=gjjyQiGVbZ0qiNKBbeRVSWYtweXfSRNQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Michele Baldessari <michele@acksyn.org>,
	Russell King - ARM Linux <linux@arm.linux.org.uk>,
	netdev <netdev@vger.kernel.org>,
	Neal Cardwell <ncardwell@google.com>,
	Nandita Dukkipati <nanditad@google.com>
To: Yuchung Cheng <ycheng@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rydia.net ([69.46.88.68]:44285 "EHLO mail.rydia.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751234Ab3JGT4q (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 7 Oct 2013 15:56:46 -0400
In-Reply-To: <CAK6E8=czoej81t=-J=gjjyQiGVbZ0qiNKBbeRVSWYtweXfSRNQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 7 Oct 2013, Yuchung Cheng wrote:

> On Mon, Oct 7, 2013 at 11:13 AM, dormando <dormando@rydia.net> wrote:
> >
> > > >
> > > > there's been multiple reports about this one:
> > > > https://bugzilla.redhat.com/show_bug.cgi?id=989251
> > > > http://bugzilla.kernel.org/show_bug.cgi?id=60779
> > > >
> > > > Could you try Yuchung's debug patch?
> > > > http://www.spinics.net/lists/netdev/msg250193.html
> > > Yes it looks like the same bug. Please try that patch to help identify
> > > this elusive bug.
> > >
> >
> > Hi!
> >
> > We get this one a few times a day in production. Here's a warning with
> > your debug trace in the line immediately following:
> > (I censored a few things)
> >
> >  [125311.721950] ------------[ cut here ]------------
> >  [125311.721961] WARNING: at net/ipv4/tcp_input.c:2776 tcp_fastretrans_alert+0xb58/0xc80()
> >  [125311.721962] Modules linked in: bridge ip_vs macvlan coretemp crc32_pclmul ghash_clmulni_intel gpio_ich ipmi_watchdog microcode ipmi_devintf sb_edac lpc_ich edac_core mfd_core ipmi_si ipmi_msghandler iptable_nat nf_nat_ipv4 nf_nat ixgbe igb mdio i2c_algo_bit ptp pps_core
> >  [125311.721981] CPU: 11 PID: 0 Comm: swapper/11 Not tainted 3.10.13 #1
> >  [125311.721982] Hardware name: Supermicro XXXXXXXXXXX, BIOS 1.1 10/03/2012
> >  [125311.721984]  ffffffff81a82007 ffff88407fc63958 ffffffff816bb9cc ffff88407fc63998
> >  [125311.721986]  ffffffff8104b940 00ff8840ad904f82 ffff883b8a165b00 0000000000004120
> >  [125311.721989]  0000000000000001 0000000000000019 0000000000000000 ffff88407fc639a8
> >  [125311.721991] Call Trace:
> >  [125311.721992]  <IRQ>  [<ffffffff816bb9cc>] dump_stack+0x19/0x1d
> >  [125311.722002]  [<ffffffff8104b940>] warn_slowpath_common+0x70/0xa0
> >  [125311.722005]  [<ffffffff8104b98a>] warn_slowpath_null+0x1a/0x20
> >  [125311.722007]  [<ffffffff81616db8>] tcp_fastretrans_alert+0xb58/0xc80
> >  [125311.722011]  [<ffffffff8161891f>] tcp_ack+0x6df/0xe90
> >  [125311.722016]  [<ffffffff8164e0ca>] ? ipt_do_table+0x22a/0x680
> >  [125311.722018]  [<ffffffff816194b3>] ? tcp_validate_incoming+0x63/0x320
> >  [125311.722021]  [<ffffffff8161a55c>] tcp_rcv_established+0x2cc/0x810
> >  [125311.722023]  [<ffffffff81622c84>] tcp_v4_do_rcv+0x254/0x4f0
> >  [125311.722025]  [<ffffffff816245ac>] tcp_v4_rcv+0x5fc/0x750
> >  [125311.722027]  [<ffffffff815ffa00>] ? ip_rcv+0x350/0x350
> >  [125311.722032]  [<ffffffff815df3ad>] ? nf_hook_slow+0x7d/0x160
> >  [125311.722034]  [<ffffffff815ffa00>] ? ip_rcv+0x350/0x350
> >  [125311.722036]  [<ffffffff815fface>] ip_local_deliver_finish+0xce/0x250
> >  [125311.722037]  [<ffffffff815ffc9c>] ip_local_deliver+0x4c/0x80
> >  [125311.722039]  [<ffffffff815ff329>] ip_rcv_finish+0x119/0x360
> >  [125311.722040]  [<ffffffff815ff8e0>] ip_rcv+0x230/0x350
> >  [125311.722046]  [<ffffffff815b4067>] __netif_receive_skb_core+0x477/0x600
> >  [125311.722049]  [<ffffffff815b4217>] __netif_receive_skb+0x27/0x70
> >  [125311.722051]  [<ffffffff815b4354>] process_backlog+0xf4/0x1e0
> >  [125311.722053]  [<ffffffff815b4b45>] net_rx_action+0xf5/0x250
> >  [125311.722056]  [<ffffffff81053a5f>] __do_softirq+0xef/0x270
> >  [125311.722058]  [<ffffffff81053cb5>] irq_exit+0x95/0xa0
> >  [125311.722062]  [<ffffffff816c8f26>] do_IRQ+0x66/0xe0
> >  [125311.722065]  [<ffffffff816bf62a>] common_interrupt+0x6a/0x6a
> >  [125311.722065]  <EOI>  [<ffffffff8100abf1>] ? default_idle+0x21/0xc0
> >  [125311.722082]  [<ffffffff8100a54f>] arch_cpu_idle+0xf/0x20
> >  [125311.722086]  [<ffffffff8108f353>] cpu_startup_entry+0xb3/0x230
> >  [125311.722091]  [<ffffffff816b439e>] start_secondary+0x1dc/0x1e3
> >  [125311.722093] ---[ end trace e77cd5ba583fcbe9 ]---
> >  [125311.722096] 355.355.1.355:22496 F0x4120 S1 s7 IF25+17-1-24f0 ur57 rr3 rt0 um0 hs23120 nxt23120
> >
> > It's been happening with all 3.10 kernels, and the one above is .13 as
> > stated in the trace.
>
> Thanks! could you post the output of `sysctl -a |grep tcp`?
>
> I suspect tcp_process_tlp_ack() should not revert state to Open
> directly, but calling tcp_try_keep_open() instead, similar to all the
> undo processing in the tcp_fastretrans_alert(): after
> tcp_end_cwnd_reduction(), the process (E) falls back to check other
> stats before moving to CA_Open.
>
>
> index 9c62257..9012b42 100644
> --- a/net/ipv4/tcp_input.c
> +++ b/net/ipv4/tcp_input.c
> @@ -3314,7 +3314,7 @@ static void tcp_process_tlp_ack(struct sock *sk, u32 ack,
>                         tcp_init_cwnd_reduction(sk, true);
>                         tcp_set_ca_state(sk, TCP_CA_CWR);
>                         tcp_end_cwnd_reduction(sk);
> -                       tcp_set_ca_state(sk, TCP_CA_Open);
> +                       tcp_try_keep_open(sk);
>                         NET_INC_STATS_BH(sock_net(sk),
>                                          LINUX_MIB_TCPLOSSPROBERECOVERY);
>                 }
>

Should I apply this and see if the warning stops?

net.ipv4.tcp_abort_on_overflow = 0
net.ipv4.tcp_adv_win_scale = 1
net.ipv4.tcp_allowed_congestion_control = cubic reno
net.ipv4.tcp_app_win = 31
net.ipv4.tcp_available_congestion_control = cubic reno westwood
net.ipv4.tcp_base_mss = 512
net.ipv4.tcp_challenge_ack_limit = 100
net.ipv4.tcp_congestion_control = cubic
net.ipv4.tcp_dma_copybreak = 262144
net.ipv4.tcp_dsack = 1
net.ipv4.tcp_early_retrans = 3
net.ipv4.tcp_ecn = 2
net.ipv4.tcp_fack = 1
net.ipv4.tcp_fastopen = 0
net.ipv4.tcp_fastopen_key = 009dc92c-82e3e514-d440ed23-c49b1a89
net.ipv4.tcp_fin_timeout = 5
net.ipv4.tcp_frto = 0
net.ipv4.tcp_keepalive_intvl = 75
net.ipv4.tcp_keepalive_probes = 9
net.ipv4.tcp_keepalive_time = 1800
net.ipv4.tcp_limit_output_bytes = 131072
net.ipv4.tcp_low_latency = 0
net.ipv4.tcp_max_orphans = 2000000
net.ipv4.tcp_max_ssthresh = 0
net.ipv4.tcp_max_syn_backlog = 65536
net.ipv4.tcp_max_tw_buckets = 2000000
net.ipv4.tcp_mem = 6188001	8250670	12376002
net.ipv4.tcp_moderate_rcvbuf = 1
net.ipv4.tcp_mtu_probing = 0
net.ipv4.tcp_no_metrics_save = 1
net.ipv4.tcp_orphan_retries = 0
net.ipv4.tcp_reordering = 3
net.ipv4.tcp_retrans_collapse = 1
net.ipv4.tcp_retries1 = 3
net.ipv4.tcp_retries2 = 15
net.ipv4.tcp_rfc1337 = 0
net.ipv4.tcp_rmem = 4096	87380	16777216
net.ipv4.tcp_sack = 1
net.ipv4.tcp_slow_start_after_idle = 0
net.ipv4.tcp_stdurg = 0
net.ipv4.tcp_syn_retries = 6
net.ipv4.tcp_synack_retries = 5
net.ipv4.tcp_syncookies = 1
net.ipv4.tcp_thin_dupack = 0
net.ipv4.tcp_thin_linear_timeouts = 0
net.ipv4.tcp_timestamps = 1
net.ipv4.tcp_tso_win_divisor = 3
net.ipv4.tcp_tw_recycle = 0
net.ipv4.tcp_tw_reuse = 0
net.ipv4.tcp_user_cwnd_max = 20
net.ipv4.tcp_window_scaling = 1
net.ipv4.tcp_wmem = 4096	65536	16777216
net.ipv4.tcp_workaround_signed_windows = 0
net.ipv4.vs.secure_tcp = 0
