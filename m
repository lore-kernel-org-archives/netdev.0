From: Jean-Michel Hautbois <jhautbois@gmail.com>
Subject: Difficulties to get 1Gbps on be2net ethernet card
Date: Tue, 29 May 2012 16:46:17 +0200
Message-ID: <CAL8zT=hHAc5-wGMKgumV=K9jG6tDxzej9Dffe9UYQ24gdWQRtw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f174.google.com ([74.125.82.174]:49574 "EHLO
	mail-we0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752577Ab2E2Oqk convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 May 2012 10:46:40 -0400
Received: by weyu7 with SMTP id u7so2633739wey.19
        for <netdev@vger.kernel.org>; Tue, 29 May 2012 07:46:39 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi list,

I am using a NC553i ethernet card connected on a=C2=A0HP 10GbE Flex-10.
I am sending UDP multicast packets from one blade to another (HP
ProLiant BL460c G7) which has stricly the same HW.

I have lots of packet loss from Tx to Rx, and I can't understand why.
I suspected TX coalescing but since 3.4 I can't set this parameter
(and adaptive-tx is on by default).
I have tried the same test with a debian lenny (2.6.26 kernel and HP
drivers) and it works very well (adaptive-tx is off).

Here is the netstat (from Tx point of view) :

$> netstat -s eth1 > before ; sleep 10 ; netstat -s eth1 > after
$> beforeafter before after
Ip:
    280769 total packets received
    4 with invalid addresses
    0 forwarded
    0 incoming packets discarded
    275063 incoming packets delivered
    305430 requests sent out
    0 dropped because of missing route
Icmp:
    0 ICMP messages received
    0 input ICMP message failed.
    ICMP input histogram:
        destination unreachable: 0
        echo requests: 0
    0 ICMP messages sent
    0 ICMP messages failed
    ICMP output histogram:
        destination unreachable: 0
        echo replies: 0
IcmpMsg:
        InType3: 0
        InType8: 0
        OutType0: 0
        OutType3: 0
Tcp:
    18 active connections openings
    18 passive connection openings
    0 failed connection attempts
    0 connection resets received
    0 connections established
    3681 segments received
    3650 segments send out
    0 segments retransmited
    0 bad segments received.
    0 resets sent
Udp:
    12626 packets received
    0 packets to unknown port received.
    0 packet receive errors
    259025 packets sent
UdpLite:
TcpExt:
    0 invalid SYN cookies received
    0 packets pruned from receive queue because of socket buffer overru=
n
    14 TCP sockets finished time wait in fast timer
    0 packets rejects in established connections because of timestamp
    61 delayed acks sent
    0 delayed acks further delayed because of locked socket
    Quick ack mode was activated 0 times
    2924 packets directly queued to recvmsg prequeue.
    32 bytes directly in process context from backlog
    48684 bytes directly received in process context from prequeue
    232 packet headers predicted
    1991 packets header predicted and directly queued to user
    132 acknowledgments not containing data payload received
    2230 predicted acknowledgments
    0 times recovered from packet loss by selective acknowledgements
    0 congestion windows recovered without slow start after partial ack
    0 TCP data loss events
    0 timeouts after SACK recovery
    0 fast retransmits
    0 forward retransmits
    0 retransmits in slow start
    0 other TCP timeouts
    1 times receiver scheduled too late for direct processing
    0 packets collapsed in receive queue due to low socket buffer
    0 DSACKs sent for old packets
    0 DSACKs received
    0 connections reset due to unexpected data
    0 connections reset due to early user close
    0 connections aborted due to timeout
    0 times unabled to send RST due to no memory
    TCPSackShifted: 0
    TCPSackMerged: 0
    TCPSackShiftFallback: 0
    TCPBacklogDrop: 0
    TCPDeferAcceptDrop: 0
IpExt:
    InMcastPkts: -652745397
    OutMcastPkts: 301498
    InBcastPkts: 13
    InOctets: -2004227752
    OutOctets: -2096666083
    InMcastOctets: 1058181285
    OutMcastOctets: -1510963815
    InBcastOctets: 1014

And ethtool diff :
$> ethtool -S eth1 > before ; sleep 10 ; ethtool -S eth1 > after
$> beforeafter before after
NIC statistics:
     rx_crc_errors: 0
     rx_alignment_symbol_errors: 0
     rx_pause_frames: 0
     rx_control_frames: 0
     rx_in_range_errors: 0
     rx_out_range_errors: 0
     rx_frame_too_long: 0
     rx_address_mismatch_drops: 6
     rx_dropped_too_small: 0
     rx_dropped_too_short: 0
     rx_dropped_header_too_small: 0
     rx_dropped_tcp_length: 0
     rx_dropped_runt: 0
     rxpp_fifo_overflow_drop: 0
     rx_input_fifo_overflow_drop: 0
     rx_ip_checksum_errs: 0
     rx_tcp_checksum_errs: 0
     rx_udp_checksum_errs: 0
     tx_pauseframes: 0
     tx_controlframes: 0
     rx_priority_pause_frames: 0
     pmem_fifo_overflow_drop: 0
     jabber_events: 0
     rx_drops_no_pbuf: 0
     rx_drops_no_erx_descr: 0
     rx_drops_no_tpre_descr: 0
     rx_drops_too_many_frags: 0
     forwarded_packets: 0
     rx_drops_mtu: 0
     eth_red_drops: 0
     be_on_die_temperature: 0
     rxq0: rx_bytes: 0
     rxq0: rx_pkts: 0
     rxq0: rx_compl: 0
     rxq0: rx_mcast_pkts: 0
     rxq0: rx_post_fail: 0
     rxq0: rx_drops_no_skbs: 0
     rxq0: rx_drops_no_frags: 0
     txq0: tx_compl: 257113
     txq0: tx_bytes: 1038623935
     txq0: tx_pkts: 257113
     txq0: tx_reqs: 257113
     txq0: tx_wrbs: 514226
     txq0: tx_stops: 10

As you can see, there is 10 tx_stops in 10 seconds (it varies, can be 3=
 to 15).
Any thoughts ?

Regards,
JM
