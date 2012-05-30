From: Jean-Michel Hautbois <jhautbois@gmail.com>
Subject: Re: Difficulties to get 1Gbps on be2net ethernet card
Date: Wed, 30 May 2012 08:28:11 +0200
Message-ID: <CAL8zT=jKhRjVCdYRCerMzimxPAhP5Gi+JBBfuKjG-rfg-LMoVw@mail.gmail.com>
References: <CAL8zT=hHAc5-wGMKgumV=K9jG6tDxzej9Dffe9UYQ24gdWQRtw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f44.google.com ([74.125.82.44]:46205 "EHLO
	mail-wg0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751711Ab2E3G2d convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 May 2012 02:28:33 -0400
Received: by wgbdr13 with SMTP id dr13so4671222wgb.1
        for <netdev@vger.kernel.org>; Tue, 29 May 2012 23:28:32 -0700 (PDT)
In-Reply-To: <CAL8zT=hHAc5-wGMKgumV=K9jG6tDxzej9Dffe9UYQ24gdWQRtw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2012/5/29 Jean-Michel Hautbois <jhautbois@gmail.com>:
> Hi list,
>
> I am using a NC553i ethernet card connected on a=C2=A0HP 10GbE Flex-1=
0.
> I am sending UDP multicast packets from one blade to another (HP
> ProLiant BL460c G7) which has stricly the same HW.
>
> I have lots of packet loss from Tx to Rx, and I can't understand why.
> I suspected TX coalescing but since 3.4 I can't set this parameter
> (and adaptive-tx is on by default).
> I have tried the same test with a debian lenny (2.6.26 kernel and HP
> drivers) and it works very well (adaptive-tx is off).
>
> Here is the netstat (from Tx point of view) :
>
> $> netstat -s eth1 > before ; sleep 10 ; netstat -s eth1 > after
> $> beforeafter before after
> Ip:
> =C2=A0 =C2=A0280769 total packets received
> =C2=A0 =C2=A04 with invalid addresses
> =C2=A0 =C2=A00 forwarded
> =C2=A0 =C2=A00 incoming packets discarded
> =C2=A0 =C2=A0275063 incoming packets delivered
> =C2=A0 =C2=A0305430 requests sent out
> =C2=A0 =C2=A00 dropped because of missing route
> Icmp:
> =C2=A0 =C2=A00 ICMP messages received
> =C2=A0 =C2=A00 input ICMP message failed.
> =C2=A0 =C2=A0ICMP input histogram:
> =C2=A0 =C2=A0 =C2=A0 =C2=A0destination unreachable: 0
> =C2=A0 =C2=A0 =C2=A0 =C2=A0echo requests: 0
> =C2=A0 =C2=A00 ICMP messages sent
> =C2=A0 =C2=A00 ICMP messages failed
> =C2=A0 =C2=A0ICMP output histogram:
> =C2=A0 =C2=A0 =C2=A0 =C2=A0destination unreachable: 0
> =C2=A0 =C2=A0 =C2=A0 =C2=A0echo replies: 0
> IcmpMsg:
> =C2=A0 =C2=A0 =C2=A0 =C2=A0InType3: 0
> =C2=A0 =C2=A0 =C2=A0 =C2=A0InType8: 0
> =C2=A0 =C2=A0 =C2=A0 =C2=A0OutType0: 0
> =C2=A0 =C2=A0 =C2=A0 =C2=A0OutType3: 0
> Tcp:
> =C2=A0 =C2=A018 active connections openings
> =C2=A0 =C2=A018 passive connection openings
> =C2=A0 =C2=A00 failed connection attempts
> =C2=A0 =C2=A00 connection resets received
> =C2=A0 =C2=A00 connections established
> =C2=A0 =C2=A03681 segments received
> =C2=A0 =C2=A03650 segments send out
> =C2=A0 =C2=A00 segments retransmited
> =C2=A0 =C2=A00 bad segments received.
> =C2=A0 =C2=A00 resets sent
> Udp:
> =C2=A0 =C2=A012626 packets received
> =C2=A0 =C2=A00 packets to unknown port received.
> =C2=A0 =C2=A00 packet receive errors
> =C2=A0 =C2=A0259025 packets sent
> UdpLite:
> TcpExt:
> =C2=A0 =C2=A00 invalid SYN cookies received
> =C2=A0 =C2=A00 packets pruned from receive queue because of socket bu=
ffer overrun
> =C2=A0 =C2=A014 TCP sockets finished time wait in fast timer
> =C2=A0 =C2=A00 packets rejects in established connections because of =
timestamp
> =C2=A0 =C2=A061 delayed acks sent
> =C2=A0 =C2=A00 delayed acks further delayed because of locked socket
> =C2=A0 =C2=A0Quick ack mode was activated 0 times
> =C2=A0 =C2=A02924 packets directly queued to recvmsg prequeue.
> =C2=A0 =C2=A032 bytes directly in process context from backlog
> =C2=A0 =C2=A048684 bytes directly received in process context from pr=
equeue
> =C2=A0 =C2=A0232 packet headers predicted
> =C2=A0 =C2=A01991 packets header predicted and directly queued to use=
r
> =C2=A0 =C2=A0132 acknowledgments not containing data payload received
> =C2=A0 =C2=A02230 predicted acknowledgments
> =C2=A0 =C2=A00 times recovered from packet loss by selective acknowle=
dgements
> =C2=A0 =C2=A00 congestion windows recovered without slow start after =
partial ack
> =C2=A0 =C2=A00 TCP data loss events
> =C2=A0 =C2=A00 timeouts after SACK recovery
> =C2=A0 =C2=A00 fast retransmits
> =C2=A0 =C2=A00 forward retransmits
> =C2=A0 =C2=A00 retransmits in slow start
> =C2=A0 =C2=A00 other TCP timeouts
> =C2=A0 =C2=A01 times receiver scheduled too late for direct processin=
g
> =C2=A0 =C2=A00 packets collapsed in receive queue due to low socket b=
uffer
> =C2=A0 =C2=A00 DSACKs sent for old packets
> =C2=A0 =C2=A00 DSACKs received
> =C2=A0 =C2=A00 connections reset due to unexpected data
> =C2=A0 =C2=A00 connections reset due to early user close
> =C2=A0 =C2=A00 connections aborted due to timeout
> =C2=A0 =C2=A00 times unabled to send RST due to no memory
> =C2=A0 =C2=A0TCPSackShifted: 0
> =C2=A0 =C2=A0TCPSackMerged: 0
> =C2=A0 =C2=A0TCPSackShiftFallback: 0
> =C2=A0 =C2=A0TCPBacklogDrop: 0
> =C2=A0 =C2=A0TCPDeferAcceptDrop: 0
> IpExt:
> =C2=A0 =C2=A0InMcastPkts: -652745397
> =C2=A0 =C2=A0OutMcastPkts: 301498
> =C2=A0 =C2=A0InBcastPkts: 13
> =C2=A0 =C2=A0InOctets: -2004227752
> =C2=A0 =C2=A0OutOctets: -2096666083
> =C2=A0 =C2=A0InMcastOctets: 1058181285
> =C2=A0 =C2=A0OutMcastOctets: -1510963815
> =C2=A0 =C2=A0InBcastOctets: 1014
>
> And ethtool diff :
> $> ethtool -S eth1 > before ; sleep 10 ; ethtool -S eth1 > after
> $> beforeafter before after
> NIC statistics:
> =C2=A0 =C2=A0 rx_crc_errors: 0
> =C2=A0 =C2=A0 rx_alignment_symbol_errors: 0
> =C2=A0 =C2=A0 rx_pause_frames: 0
> =C2=A0 =C2=A0 rx_control_frames: 0
> =C2=A0 =C2=A0 rx_in_range_errors: 0
> =C2=A0 =C2=A0 rx_out_range_errors: 0
> =C2=A0 =C2=A0 rx_frame_too_long: 0
> =C2=A0 =C2=A0 rx_address_mismatch_drops: 6
> =C2=A0 =C2=A0 rx_dropped_too_small: 0
> =C2=A0 =C2=A0 rx_dropped_too_short: 0
> =C2=A0 =C2=A0 rx_dropped_header_too_small: 0
> =C2=A0 =C2=A0 rx_dropped_tcp_length: 0
> =C2=A0 =C2=A0 rx_dropped_runt: 0
> =C2=A0 =C2=A0 rxpp_fifo_overflow_drop: 0
> =C2=A0 =C2=A0 rx_input_fifo_overflow_drop: 0
> =C2=A0 =C2=A0 rx_ip_checksum_errs: 0
> =C2=A0 =C2=A0 rx_tcp_checksum_errs: 0
> =C2=A0 =C2=A0 rx_udp_checksum_errs: 0
> =C2=A0 =C2=A0 tx_pauseframes: 0
> =C2=A0 =C2=A0 tx_controlframes: 0
> =C2=A0 =C2=A0 rx_priority_pause_frames: 0
> =C2=A0 =C2=A0 pmem_fifo_overflow_drop: 0
> =C2=A0 =C2=A0 jabber_events: 0
> =C2=A0 =C2=A0 rx_drops_no_pbuf: 0
> =C2=A0 =C2=A0 rx_drops_no_erx_descr: 0
> =C2=A0 =C2=A0 rx_drops_no_tpre_descr: 0
> =C2=A0 =C2=A0 rx_drops_too_many_frags: 0
> =C2=A0 =C2=A0 forwarded_packets: 0
> =C2=A0 =C2=A0 rx_drops_mtu: 0
> =C2=A0 =C2=A0 eth_red_drops: 0
> =C2=A0 =C2=A0 be_on_die_temperature: 0
> =C2=A0 =C2=A0 rxq0: rx_bytes: 0
> =C2=A0 =C2=A0 rxq0: rx_pkts: 0
> =C2=A0 =C2=A0 rxq0: rx_compl: 0
> =C2=A0 =C2=A0 rxq0: rx_mcast_pkts: 0
> =C2=A0 =C2=A0 rxq0: rx_post_fail: 0
> =C2=A0 =C2=A0 rxq0: rx_drops_no_skbs: 0
> =C2=A0 =C2=A0 rxq0: rx_drops_no_frags: 0
> =C2=A0 =C2=A0 txq0: tx_compl: 257113
> =C2=A0 =C2=A0 txq0: tx_bytes: 1038623935
> =C2=A0 =C2=A0 txq0: tx_pkts: 257113
> =C2=A0 =C2=A0 txq0: tx_reqs: 257113
> =C2=A0 =C2=A0 txq0: tx_wrbs: 514226
> =C2=A0 =C2=A0 txq0: tx_stops: 10
>
> As you can see, there is 10 tx_stops in 10 seconds (it varies, can be=
 3 to 15).
> Any thoughts ?
>
> Regards,
> JM

If this can help, setting tx queue length to 5000 seems to make the
problem disappear.
I didn't specified it : MTU is 4096, UDP packets are 4000 bytes.

JM
