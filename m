From: Alexey Vlasov <renton@renton.name>
Subject: Re: Packet time delays on multi-core systems
Date: Fri, 1 Oct 2010 18:18:58 +0400
Message-ID: <20101001141858.GE4094@beaver.vrungel.ru>
References: <20100930062419.GD86786@beaver.vrungel.ru> <1285828432.5211.812.camel@edumazet-laptop> <20100930122321.GA1575@beaver.vrungel.ru> <1285850669.2615.426.camel@edumazet-laptop> <20100930173732.GB4094@beaver.vrungel.ru> <1285869782.2615.920.camel@edumazet-laptop> <20100930181556.GC4094@beaver.vrungel.ru> <1285872765.2615.1008.camel@edumazet-laptop> <20101001101650.GD4094@beaver.vrungel.ru> <1285937966.2641.117.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=koi8-r
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.df.ru ([195.42.160.16]:48770 "EHLO smtp.df.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932151Ab0JAOUy (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 1 Oct 2010 10:20:54 -0400
Content-Disposition: inline
In-Reply-To: <1285937966.2641.117.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Oct 01, 2010 at 02:59:26PM +0200, Eric Dumazet wrote:
> Le vendredi 01 octobre 2010 ?? 14:16 +0400, Alexey Vlasov a ??crit :
> 
> > I have also found that:
> > 1. rx overruns is increasing.
> > 2. rx_queue_drop_packet_count is increasing.
> 
> So you flood machine with packets, its not an idle one ?
> 
> I thought you were doing experiments with light trafic.

No, it's a usual working server for shared hosting. There're about 1000 
clients' website, and I don't flood it specially. Franlky speaking I don't 
see any network suspicious activity.
 
> > # ethtool -S eth0 | grep drop
> >      tx_dropped: 0
> >      rx_queue_drop_packet_count: 1260743751
> >      dropped_smbus: 0
> >      rx_queue_0_drops: 0
> >      rx_queue_1_drops: 0
> >      rx_queue_2_drops: 0
> >      rx_queue_3_drops: 0
> > 
> 
> 
> ethtool -S eth0   (full output, not small parts)

NIC statistics:
     rx_packets: 2973717440
     tx_packets: 3032670910
     rx_bytes: 1892633650741
     tx_bytes: 2536130682695
     rx_broadcast: 118773199
     tx_broadcast: 68013
     rx_multicast: 95257
     tx_multicast: 0
     rx_errors: 0
     tx_errors: 0
     tx_dropped: 0
     multicast: 95257
     collisions: 0
     rx_length_errors: 0
     rx_over_errors: 0
     rx_crc_errors: 0
     rx_frame_errors: 0
     rx_no_buffer_count: 7939
     rx_queue_drop_packet_count: 1324025520
     rx_missed_errors: 146631
     tx_aborted_errors: 0
     tx_carrier_errors: 0
     tx_fifo_errors: 0
     tx_heartbeat_errors: 0
     tx_window_errors: 0
     tx_abort_late_coll: 0
     tx_deferred_ok: 0
     tx_single_coll_ok: 0
     tx_multi_coll_ok: 0
     tx_timeout_count: 0
     tx_restart_queue: 50715
     rx_long_length_errors: 0
     rx_short_length_errors: 0
     rx_align_errors: 0
     tx_tcp_seg_good: 344724062
     tx_tcp_seg_failed: 0
     rx_flow_control_xon: 0
     rx_flow_control_xoff: 0
     tx_flow_control_xon: 0
     tx_flow_control_xoff: 0
     rx_long_byte_count: 1892633650741
     rx_csum_offload_good: 2973697420
     rx_csum_offload_errors: 6235
     tx_dma_out_of_sync: 0
     alloc_rx_buff_failed: 0
     tx_smbus: 9327
     rx_smbus: 118531661
     dropped_smbus: 0
     tx_queue_0_packets: 797617475
     tx_queue_0_bytes: 630191908685
     tx_queue_1_packets: 719681297
     tx_queue_1_bytes: 625907304846
     tx_queue_2_packets: 718841556
     tx_queue_2_bytes: 620522418855
     tx_queue_3_packets: 796521255
     tx_queue_3_bytes: 646196024585
     rx_queue_0_packets: 788885797
     rx_queue_0_bytes: 458936338699
     rx_queue_0_drops: 0
     rx_queue_1_packets: 701354604
     rx_queue_1_bytes: 457490536453
     rx_queue_1_drops: 0
     rx_queue_2_packets: 791887663
     rx_queue_2_bytes: 534425333616
     rx_queue_2_drops: 0
     rx_queue_3_packets: 691579028
     rx_queue_3_bytes: 429887244557
     rx_queue_3_drops: 0

> > 3. By sending SYN-packets by hping, RST packet doesn't send, but I don't know may 
> > be it is just some feature in 2.6.32.
> > newbox # hping -c 1 -S -p 80 111.111.111.111
> > HPING 111.111.111.111 (eth0 111.111.111.111): S set, 40 headers + 0 data bytes
> > len=46 ip=111.111.111.111 ttl=58 DF id=11471 sport=80 flags=SA seq=0 win=65535 rtt=99.0 ms
> > 
> > --- 111.111.111.111 hping statistic ---
> > 1 packets tramitted, 1 packets received, 0% packet loss
> > round-trip min/avg/max = 99.0/99.0/99.0 ms
> > 
> > 13:59:07.439528 IP newbox.2777 > 111.111.111.111.80: S 345595033:345595033(0) win 512
> > 13:59:07.439626 IP 111.111.111.111.80 > newbox.2777: S 1178827395:1178827395(0) ack 345595034 win 65535 <mss 1460>
> > 13:59:10.439368 IP 111.111.111.111.80 > newbox.2777: S 1178827395:1178827395(0) ack 345595034 win 65535 <mss 1460>
> > 13:59:16.439313 IP 111.111.111.111.80 > newbox.2777: S 1178827395:1178827395(0) ack 345595034 win 65535 <mss 1460>
> > 13:59:28.439206 IP 111.111.111.111.80 > newbox.2777: S 1178827395:1178827395(0) ack 345595034 win 65535 <mss 1460>
> > 
> > As a result I got doubles:
> 
> Are you playing with trafic shaping ?
> 
> tc -s -d qdisc
 
No, nothing alike, no shapers.

# tc -s -d qdisc
bash: tc: command not found
 
> > DUP! len=46 ip=111.111.111.111 ttl=58 DF id=27454 sport=80 flags=SA seq=0 win=65535 rtt=3137.8 ms
> > 
> > Example of another TCP-session from 2.6.28 kernel:
> > oldbox # hping -c 1 -S -p 80 111.111.111.111
> > HPING 111.111.111.111 (eth0 111.111.111.111): S set, 40 headers + 0 data bytes
> > len=46 ip=111.111.111.111 ttl=58 DF id=53180 sport=80 flags=SA seq=0 win=65535 rtt=2.9 ms
> > 
> > --- 111.111.111.111 hping statistic ---
> > 1 packets tramitted, 1 packets received, 0% packet loss
> > round-trip min/avg/max = 2.9/2.9/2.9 ms
> > 
> > 14:01:45.225136 IP oldbox.2776 > 111.111.111.111.80: S 1983626200:1983626200(0) win 512
> > 14:01:45.225288 IP 111.111.111.111.80 > oldbox.2776: S 3796385036:3796385036(0) ack 1983626201 win 65535 <mss 1460>
> > 14:01:45.227990 IP oldbox.2776 > 111.111.111.111.80: R 1983626201:1983626201(0) win 0
> > 

-- 
BRGDS. Alexey Vlasov.
