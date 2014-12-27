From: Bruno =?UTF-8?B?UHLDqW1vbnQ=?= <bonbons@linux-vserver.org>
Subject: Re: Marvell Kirkwood - MV643XX: near 100% UDP RX packet loss
Date: Sat, 27 Dec 2014 12:17:27 +0100
Message-ID: <20141227121727.20fe52c8@neptune.home>
References: <20141224001844.15e13db8@neptune.home>
	<549C878B.3030308@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>,
	netdev@vger.kernel.org
To: Rick Jones <rick.jones2@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from hygieia.santi-shop.eu ([78.46.175.2]:43410 "EHLO
	hygieia.santi-shop.eu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750826AbaL0LRd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 27 Dec 2014 06:17:33 -0500
In-Reply-To: <549C878B.3030308@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 25 December 2014 Rick Jones <rick.jones2@hp.com> wrote:
> > Why are so many packets being discarded?
> 
> You should also check the netstat statistics, particularly UDP on the 
> receiving side.  Look before and after the test and see how they change, 
> if at all.

Here they go.

Summary of numbers:
iperf UDP run, 5 seconds @ 1Gb/s
 lost 71216/71776 packets

                                  before      after      delta
ethtool:
 rx_packets:                      420001     688424     268423
 rx_bytes:                     433251917  809803463  376551546
 rx_errors:                            0          0          0
 rx_dropped:                           0          0          0
 bad_octets_received:                  0          0          0
 bad_frames_received:                  0          0          0
 rx_discard:                      159691     323123     163432
 rx_overrun:                           0          0          0
netstat, udp:
 packets received                  15559      16137        578
 packets to unknown port received     18         18          0
 packet receive errors             41599      83890      42291
 packets sent                      34697      34770         73
 receive buffer errors                 0          0          0
 send buffer errors                    0          0          0



Details of numbers:

ethtool -S eth0; netstat -ns; iperf3 -s -p 3740; netstat -ns; ethtool -S eth0                                                             
NIC statistics:
     rx_packets: 420001
     tx_packets: 158940
     rx_bytes: 433251917
     tx_bytes: 51728533
     rx_errors: 0
     tx_errors: 0
     rx_dropped: 0
     tx_dropped: 0
     good_octets_received: 652309262
     bad_octets_received: 0
     internal_mac_transmit_err: 0
     good_frames_received: 579692
     bad_frames_received: 0
     broadcast_frames_received: 3916
     multicast_frames_received: 4369
     frames_64_octets: 14938
     frames_65_to_127_octets: 133791
     frames_128_to_255_octets: 106501
     frames_256_to_511_octets: 2974
     frames_512_to_1023_octets: 80262
     frames_1024_to_max_octets: 400166
     good_octets_sent: 52557543
     good_frames_sent: 158940
     excessive_collision: 0
     multicast_frames_sent: 428
     broadcast_frames_sent: 9352
     unrec_mac_control_received: 0
     fc_sent: 0
     good_fc_received: 0
     bad_fc_received: 0
     undersize_received: 0
     fragments_received: 0
     oversize_received: 0
     jabber_received: 0
     mac_receive_error: 0
     bad_crc_event: 0
     collision: 0
     late_collision: 0
     rx_discard: 159691
     rx_overrun: 0
Ip:
    416522 total packets received
    8 with invalid addresses
    0 forwarded
    0 incoming packets discarded
    193528 incoming packets delivered
    164801 requests sent out
    2 outgoing packets dropped
    512 fragments dropped after timeout
    265053 reassemblies required
    42444 packets reassembled ok
    3518 packet reassembles failed
    2 fragments received ok
    4 fragments created
Icmp:
    64870 ICMP messages received
    1730 input ICMP message failed.
    ICMP input histogram:
        destination unreachable: 21090
        echo requests: 4912
        echo replies: 38868
    70216 ICMP messages sent
    0 ICMP messages failed
    ICMP output histogram:
        destination unreachable: 21090
        time exceeded: 6
        echo request: 44208
        echo replies: 4912
IcmpMsg:
        InType0: 38868
        InType3: 21090
        InType8: 4912
        OutType0: 4912
        OutType3: 21090
        OutType8: 44208
        OutType11: 6
Tcp:
    7 active connections openings
    4 passive connection openings
    0 failed connection attempts
    0 connection resets received
    5 connections established
    20099 segments received
    20688 segments send out
    0 segments retransmited
    0 bad segments received.
    0 resets sent
Udp:
    15559 packets received
    18 packets to unknown port received.
    41599 packet receive errors
    34697 packets sent
    0 receive buffer errors
    0 send buffer errors
UdpLite:
TcpExt:
    4 TCP sockets finished time wait in fast timer
    7 delayed acks sent
    5 delayed acks further delayed because of locked socket
    3 packets directly queued to recvmsg prequeue.
    254 bytes directly received in process context from prequeue
    7990 packet headers predicted
    3 packets header predicted and directly queued to user
    301 acknowledgments not containing data payload received
    10132 predicted acknowledgments
    TCPRcvCoalesce: 7843
    TCPOrigDataSent: 11810
IpExt:
    InMcastPkts: 78
    InBcastPkts: 303
    InOctets: 421982031
    OutOctets: 20785506
    InMcastOctets: 2184
    InBcastOctets: 43372
    InNoECTPkts: 416523
-----------------------------------------------------------
Server listening on 3740
-----------------------------------------------------------
Accepted connection from 192.168.0.139, port 36178
[  5] local 192.168.0.70 port 3740 connected to 192.168.0.139 port 55831
[ ID] Interval           Transfer     Bandwidth       Jitter    Lost/Total Datagrams
[  5]   0.00-1.02   sec   736 KBytes  5.93 Mbits/sec  7.017 ms  11481/11573 (99%)  
[  5]   1.02-2.02   sec   368 KBytes  3.01 Mbits/sec  9.887 ms  14867/14913 (1e+02%)  
[  5]   2.02-3.02   sec   560 KBytes  4.59 Mbits/sec  5.791 ms  14528/14598 (1e+02%)  
[  5]   3.02-4.02   sec   984 KBytes  8.06 Mbits/sec  7.613 ms  13972/14095 (99%)  
[  5]   4.02-5.04   sec  1.66 MBytes  13.7 Mbits/sec  4.602 ms  15842/16055 (99%)  
[  5]   5.04-5.25   sec   128 KBytes  4.80 Mbits/sec  3.809 ms  526/542 (97%)  
- - - - - - - - - - - - - - - - - - - - - - - - -
[ ID] Interval           Transfer     Bandwidth       Jitter    Lost/Total Datagrams
[  5]   0.00-5.25   sec   562 MBytes   897 Mbits/sec  3.809 ms  71216/71776 (99%)  
-----------------------------------------------------------
Server listening on 3740
-----------------------------------------------------------
^Ciperf3: interrupt - the server has terminated
Ip:
    684863 total packets received
    8 with invalid addresses
    0 forwarded
    0 incoming packets discarded
    236661 incoming packets delivered
    165154 requests sent out
    2 outgoing packets dropped
    512 fragments dropped after timeout
    533112 reassemblies required
    85295 packets reassembled ok
    6421 packet reassembles failed
    2 fragments received ok
    4 fragments created
Icmp:
    65021 ICMP messages received
    1737 input ICMP message failed.
    ICMP input histogram:
        destination unreachable: 21144
        echo requests: 4923
        echo replies: 38954
    70380 ICMP messages sent
    0 ICMP messages failed
    ICMP output histogram:
        destination unreachable: 21144
        time exceeded: 6
        echo request: 44307
        echo replies: 4923
IcmpMsg:
        InType0: 38954
        InType3: 21144
        InType8: 4923
        OutType0: 4923
        OutType3: 21144
        OutType8: 44307
        OutType11: 6
Tcp:
    7 active connections openings
    5 passive connection openings
    0 failed connection attempts
    0 connection resets received
    5 connections established
    20203 segments received
    20803 segments send out
    0 segments retransmited
    0 bad segments received.
    0 resets sent
Udp:
    16137 packets received
    18 packets to unknown port received.
    83890 packet receive errors
    34770 packets sent
    0 receive buffer errors
    0 send buffer errors
UdpLite:
TcpExt:
    4 TCP sockets finished time wait in fast timer
    9 delayed acks sent
    5 delayed acks further delayed because of locked socket
    6 packets directly queued to recvmsg prequeue.
    510 bytes directly received in process context from prequeue
    8008 packet headers predicted
    6 packets header predicted and directly queued to user
    304 acknowledgments not containing data payload received
    10211 predicted acknowledgments
    TCPRcvCoalesce: 7859
    TCPOrigDataSent: 11904
IpExt:
    InMcastPkts: 78
    InBcastPkts: 303
    InOctets: 793681544
    OutOctets: 20825320
    InMcastOctets: 2184
    InBcastOctets: 43372
    InNoECTPkts: 684865
NIC statistics:
     rx_packets: 688424
     tx_packets: 159342
     rx_bytes: 809803463
     tx_bytes: 51782065
     rx_errors: 0
     tx_errors: 0
     rx_dropped: 0
     tx_dropped: 0
     good_octets_received: 1258435196
     bad_octets_received: 0
     internal_mac_transmit_err: 0
     good_frames_received: 1011547
     bad_frames_received: 0
     broadcast_frames_received: 3926
     multicast_frames_received: 4384
     frames_64_octets: 14978
     frames_65_to_127_octets: 134201
     frames_128_to_255_octets: 106794
     frames_256_to_511_octets: 3006
     frames_512_to_1023_octets: 152189
     frames_1024_to_max_octets: 759721
     good_octets_sent: 52613183
     good_frames_sent: 159342
     excessive_collision: 0
     multicast_frames_sent: 428
     broadcast_frames_sent: 9378
     unrec_mac_control_received: 0
     fc_sent: 0
     good_fc_received: 0
     bad_fc_received: 0
     undersize_received: 0
     fragments_received: 0
     oversize_received: 0
     jabber_received: 0
     mac_receive_error: 0
     bad_crc_event: 0
     collision: 0
     late_collision: 0
     rx_discard: 323123
     rx_overrun: 0



iperf on client side:
iperf3 -p 3740 -t 5 -b 0 -u -4 -c sheevaplug
Connecting to host sheevaplug, port 3740
[  4] local 192.168.0.139 port 55831 connected to 192.168.0.70 port 3740
[ ID] Interval           Transfer     Bandwidth       Total Datagrams
[  4]   0.00-1.00   sec   114 MBytes   959 Mbits/sec  14630  
[  4]   1.00-2.00   sec   114 MBytes   959 Mbits/sec  14630  
[  4]   2.00-3.00   sec   114 MBytes   954 Mbits/sec  14560  
[  4]   3.00-4.00   sec   110 MBytes   926 Mbits/sec  14130  
[  4]   4.00-5.00   sec   109 MBytes   915 Mbits/sec  13960  
- - - - - - - - - - - - - - - - - - - - - - - - -
[ ID] Interval           Transfer     Bandwidth       Jitter    Lost/Total Datagrams
[  4]   0.00-5.00   sec   562 MBytes   943 Mbits/sec  3.809 ms  71216/71776 (99%)  
[  4] Sent 71776 datagrams

iperf Done.
