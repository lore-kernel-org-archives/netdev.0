From: Jesse Brandeburg <jesse.brandeburg@gmail.com>
Subject: Re: Problem with ixgbe and TX locked on one cpu
Date: Tue, 18 Oct 2011 11:57:33 -0700
Message-ID: <CAEuXFEy89F_=J_PJMSbQ1fDcOEkkpz2vucq3LcToi7rTcZHcDA@mail.gmail.com>
References: <4E988B1E.5000606@itcare.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-2
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Linux Network Development list <netdev@vger.kernel.org>,
	e1000-devel@lists.sourceforge.net
To: =?ISO-8859-2?Q?Pawe=B3_Staszewski?= <pstaszewski@itcare.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f46.google.com ([209.85.214.46]:59328 "EHLO
	mail-bw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751797Ab1JRS5e convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 Oct 2011 14:57:34 -0400
Received: by bkbzt19 with SMTP id zt19so1122450bkb.19
        for <netdev@vger.kernel.org>; Tue, 18 Oct 2011 11:57:33 -0700 (PDT)
In-Reply-To: <4E988B1E.5000606@itcare.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

CC: e1000-devel

2011/10/14 Pawe=B3 Staszewski <pstaszewski@itcare.pl>:
> Hello
>
> I have weird problem with ixgbe and irq affinity / rx-tx queue assign=
ment

what application are you running, how are you using ixgbe? looks like
a router.  is something changing the skb->rx_queue entry (like
netfilter) or is there a layered device above ixgbe (bonding or ...) ?

why do your interrupts move after a long period? did you do it by
hand? we recommend disabling irqbalance and hand tuning interrupts
possibly with the set_irq_affinity.sh script.

> Statistics for my ethernet - ixgbe driver:
> ethtool -S eth4
> NIC statistics:
> =A0 =A0 rx_packets: 5815535848808
> =A0 =A0 tx_packets: 5811202378421
> =A0 =A0 rx_bytes: 4791001750842200
> =A0 =A0 tx_bytes: 4781190419358301
> =A0 =A0 rx_pkts_nic: 5815535848827
> =A0 =A0 tx_pkts_nic: 5811202378510
> =A0 =A0 rx_bytes_nic: 4837563124411799
> =A0 =A0 tx_bytes_nic: 4829987507084013
> =A0 =A0 lsc_int: 8
> =A0 =A0 tx_busy: 0
> =A0 =A0 non_eop_descs: 0
> =A0 =A0 rx_errors: 0
> =A0 =A0 tx_errors: 0
> =A0 =A0 rx_dropped: 0
> =A0 =A0 tx_dropped: 0
> =A0 =A0 multicast: 92494273
> =A0 =A0 broadcast: 268718206
> =A0 =A0 rx_no_buffer_count: 28829
> =A0 =A0 collisions: 0
> =A0 =A0 rx_over_errors: 0
> =A0 =A0 rx_crc_errors: 0
> =A0 =A0 rx_frame_errors: 0
> =A0 =A0 hw_rsc_aggregated: 0
> =A0 =A0 hw_rsc_flushed: 0
> =A0 =A0 fdir_match: 0
> =A0 =A0 fdir_miss: 0
> =A0 =A0 rx_fifo_errors: 0
> =A0 =A0 rx_missed_errors: 307051074
> =A0 =A0 tx_aborted_errors: 0
> =A0 =A0 tx_carrier_errors: 0
> =A0 =A0 tx_fifo_errors: 0
> =A0 =A0 tx_heartbeat_errors: 0
> =A0 =A0 tx_timeout_count: 0
> =A0 =A0 tx_restart_queue: 15926219
> =A0 =A0 rx_long_length_errors: 298
> =A0 =A0 rx_short_length_errors: 0
> =A0 =A0 tx_flow_control_xon: 0
> =A0 =A0 rx_flow_control_xon: 0
> =A0 =A0 tx_flow_control_xoff: 0
> =A0 =A0 rx_flow_control_xoff: 0
> =A0 =A0 rx_csum_offload_errors: 54173917
> =A0 =A0 alloc_rx_page_failed: 0
> =A0 =A0 alloc_rx_buff_failed: 0
> =A0 =A0 rx_no_dma_resources: 0
> =A0 =A0 tx_queue_0_packets: 68694825
> =A0 =A0 tx_queue_0_bytes: 9443750332
> =A0 =A0 tx_queue_1_packets: 8410961
> =A0 =A0 tx_queue_1_bytes: 2527763233
> =A0 =A0 tx_queue_2_packets: 14411252
> =A0 =A0 tx_queue_2_bytes: 1317132394
> =A0 =A0 tx_queue_3_packets: 15013508147
> =A0 =A0 tx_queue_3_bytes: 17364767277348
> =A0 =A0 tx_queue_4_packets: 62779891
> =A0 =A0 tx_queue_4_bytes: 63476596221
> =A0 =A0 tx_queue_5_packets: 11176001
> =A0 =A0 tx_queue_5_bytes: 2763600253
> =A0 =A0 tx_queue_6_packets: 4416357
> =A0 =A0 tx_queue_6_bytes: 611874984
> =A0 =A0 tx_queue_7_packets: 8933405
> =A0 =A0 tx_queue_7_bytes: 1837198524
> =A0 =A0 tx_queue_8_packets: 13292669
> =A0 =A0 tx_queue_8_bytes: 3241333510
> =A0 =A0 tx_queue_9_packets: 10747236
> =A0 =A0 tx_queue_9_bytes: 1805109931
> =A0 =A0 tx_queue_10_packets: 5795935258380
> =A0 =A0 tx_queue_10_bytes: 4763725304722245
> =A0 =A0 tx_queue_11_packets: 12073934
> =A0 =A0 tx_queue_11_bytes: 2982743045
> =A0 =A0 tx_queue_12_packets: 10523764
> =A0 =A0 tx_queue_12_bytes: 2637451199
> =A0 =A0 tx_queue_13_packets: 12480552
> =A0 =A0 tx_queue_13_bytes: 2434827407
> =A0 =A0 tx_queue_14_packets: 7401777
> =A0 =A0 tx_queue_14_bytes: 2413618099
> =A0 =A0 tx_queue_15_packets: 8269270
> =A0 =A0 tx_queue_15_bytes: 2854359576
> =A0 =A0 rx_queue_0_packets: 361373769507
> =A0 =A0 rx_queue_0_bytes: 298565751248279
> =A0 =A0 rx_queue_1_packets: 369901571908
> =A0 =A0 rx_queue_1_bytes: 303414679798160
> =A0 =A0 rx_queue_2_packets: 362508961738
> =A0 =A0 rx_queue_2_bytes: 299852439447157
> =A0 =A0 rx_queue_3_packets: 363449272013
> =A0 =A0 rx_queue_3_bytes: 299738390792515
> =A0 =A0 rx_queue_4_packets: 361876234461
> =A0 =A0 rx_queue_4_bytes: 297483366939732
> =A0 =A0 rx_queue_5_packets: 361402926316
> =A0 =A0 rx_queue_5_bytes: 297633876486533
> =A0 =A0 rx_queue_6_packets: 362261522767
> =A0 =A0 rx_queue_6_bytes: 298026696344647
> =A0 =A0 rx_queue_7_packets: 361248593301
> =A0 =A0 rx_queue_7_bytes: 296756459279986
> =A0 =A0 rx_queue_8_packets: 361654143416
> =A0 =A0 rx_queue_8_bytes: 298272433659520
> =A0 =A0 rx_queue_9_packets: 362781764710
> =A0 =A0 rx_queue_9_bytes: 298804803191595
> =A0 =A0 rx_queue_10_packets: 361386593064
> =A0 =A0 rx_queue_10_bytes: 297434987797644
> =A0 =A0 rx_queue_11_packets: 369886597895
> =A0 =A0 rx_queue_11_bytes: 302353350171712
> =A0 =A0 rx_queue_12_packets: 361582732276
> =A0 =A0 rx_queue_12_bytes: 298670408005971
> =A0 =A0 rx_queue_13_packets: 365248093536
> =A0 =A0 rx_queue_13_bytes: 302573023878287
> =A0 =A0 rx_queue_14_packets: 366571142073
> =A0 =A0 rx_queue_14_bytes: 302396739276514
> =A0 =A0 rx_queue_15_packets: 362401929830
> =A0 =A0 rx_queue_15_bytes: 299024344526029
>
> The problem is with queue 10
> =A0 =A0 tx_queue_10_packets: 5795935258380
> =A0 =A0 tx_queue_10_bytes: 4763725304722245
>
> as you can see most of the queue processing is used in queue 10
> Average difference is 1,854271229903958e-6 =A0- compared to other que=
ues
>
> and the problem is that almost all TX packet processing is on one CPU
> cat /proc/interrupts - in attached file
>
> Is this driver or kernel problem ?
>
> Kernel is: 2.6.38.2
>
> ixgbe driver is:
> ethtool -i eth4
> driver: ixgbe
> version: 3.2.9-k2
> firmware-version: 1.12-2
> bus-info: 0000:04:00.0
