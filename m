From: Bruno =?UTF-8?B?UHLDqW1vbnQ=?= <bonbons@linux-vserver.org>
Subject: Marvell Kirkwood - MV643XX: near 100% UDP RX packet loss
Date: Wed, 24 Dec 2014 00:18:44 +0100
Message-ID: <20141224001844.15e13db8@neptune.home>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from hygieia.santi-shop.eu ([78.46.175.2]:55874 "EHLO
	hygieia.santi-shop.eu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751359AbaLWXSu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Dec 2014 18:18:50 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

On a SheevaPlug, Marvell Kirkwood based, I get nearly 100% packet loss
when running iperf in UDP (rx) mode while I get ~400Gb/s in tx.
For TCP both rx and tx result in about 650Mb/s.

Running iperf server on the sheevaplug:
# iperf3 -s -p 3740

Running iperf client on a AMD APU:
# iperf3 -p 3740 -t 5 -b 0 -4 -c sheevaplug $extra

iperf output at the end.

Both systems are interconnected with a Gb/s switch [Netgear GS108E]
which successfully handles 950Mb/s between my client and a AMD turion
system (both directions, UDP as well as TCP).


Am I mis-configuring the SheevaPlug or is there some bug causing all
the UDP packets to get lost? (slow rate UDP is working fine however)


Thanks,
Bruno


On the SheevaPlug:

# uname -a
Linux sheevaplug 3.15.0-sheeva+ #1 Mon Jun 9 21:58:19 CEST 2014 armv5tel Marvell Kirkwood (Flattened Device Tree) GNU/Linux

# ethtool -g eth0
Ring parameters for eth0:
Pre-set maximums:
RX:             4096
RX Mini:        0
RX Jumbo:       0
TX:             4096
Current hardware settings:
RX:             2048             (this defaults to 128 on boot)
RX Mini:        0
RX Jumbo:       0
TX:             256

# ethtool -k eth0
Features for eth0:
rx-checksumming: on
tx-checksumming: on
        tx-checksum-ipv4: on
        tx-checksum-ip-generic: off [fixed]
        tx-checksum-ipv6: off [fixed]
        tx-checksum-fcoe-crc: off [fixed]
        tx-checksum-sctp: off [fixed]
scatter-gather: on
        tx-scatter-gather: on
        tx-scatter-gather-fraglist: off [fixed]
tcp-segmentation-offload: off
        tx-tcp-segmentation: off [fixed]
        tx-tcp-ecn-segmentation: off [fixed]
        tx-tcp6-segmentation: off [fixed]
udp-fragmentation-offload: off [fixed]
generic-segmentation-offload: on
generic-receive-offload: on
large-receive-offload: off [fixed]
rx-vlan-offload: off [fixed]
tx-vlan-offload: off [fixed]
ntuple-filters: off [fixed]
receive-hashing: off [fixed]
highdma: off [fixed]
rx-vlan-filter: off [fixed]
vlan-challenged: off [fixed]
tx-lockless: off [fixed]
netns-local: off [fixed]
tx-gso-robust: off [fixed]
tx-fcoe-segmentation: off [fixed]
tx-gre-segmentation: off [fixed]
tx-ipip-segmentation: off [fixed]
tx-sit-segmentation: off [fixed]
tx-udp_tnl-segmentation: off [fixed]
tx-mpls-segmentation: off [fixed]
fcoe-mtu: off [fixed]
tx-nocache-copy: off
loopback: off [fixed]
rx-fcs: off [fixed]
rx-all: off [fixed]
tx-vlan-stag-hw-insert: off [fixed]
rx-vlan-stag-hw-parse: off [fixed]
rx-vlan-stag-filter: off [fixed]
l2-fwd-offload: off [fixed]
busy-poll: off [fixed]


# ethtool -S eth0
NIC statistics:
     rx_packets: 6188650
     tx_packets: 5407424
     rx_bytes: 2949700388
     tx_bytes: 1527361112
     rx_errors: 0
     tx_errors: 0
     rx_dropped: 0
     tx_dropped: 0
     good_octets_received: 9696302398
     bad_octets_received: 0
     internal_mac_transmit_err: 0
     good_frames_received: 7961482
     bad_frames_received: 0
     broadcast_frames_received: 45063
     multicast_frames_received: 35667
     frames_64_octets: 390741
     frames_65_to_127_octets: 1213008
     frames_128_to_255_octets: 1159241
     frames_256_to_511_octets: 10833
     frames_512_to_1023_octets: 1123895
     frames_1024_to_max_octets: 9471171
     good_octets_sent: 5851110022
     good_frames_sent: 5407407
     excessive_collision: 0
     multicast_frames_sent: 35326
     broadcast_frames_sent: 109099
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
     rx_discard: 1772832
     rx_overrun: 0


Why are so many packets being discarded?


========= UDP ($extra = -u) ====================
Connecting to host sheevaplug, port 3740
[  4] local 192.168.0.139 port 46162 connected to 192.168.0.70 port 3740
[ ID] Interval           Transfer     Bandwidth       Total Datagrams
[  4]   0.00-1.00   sec   114 MBytes   959 Mbits/sec  14640  
[  4]   1.00-2.00   sec   114 MBytes   958 Mbits/sec  14620  
[  4]   2.00-3.00   sec   114 MBytes   958 Mbits/sec  14620  
[  4]   3.00-4.00   sec   114 MBytes   958 Mbits/sec  14620  
[  4]   4.00-5.00   sec   114 MBytes   958 Mbits/sec  14630  
- - - - - - - - - - - - - - - - - - - - - - - - -
[ ID] Interval           Transfer     Bandwidth       Jitter    Lost/Total Datagrams
[  4]   0.00-5.00   sec   571 MBytes   958 Mbits/sec  10.405 ms  72415/72673 (1e+02%)  
[  4] Sent 72673 datagrams

iperf Done.

-----------------------------------------------------------
Server listening on 3740
-----------------------------------------------------------
Accepted connection from 192.168.0.139, port 45461
[  5] local 192.168.0.70 port 3740 connected to 192.168.0.139 port 46162
[ ID] Interval           Transfer     Bandwidth       Jitter    Lost/Total Datagrams
[  5]   0.00-1.07   sec   368 KBytes  2.83 Mbits/sec  80.399 ms  5086/5132 (99%)  
[  5]   1.07-2.01   sec   280 KBytes  2.44 Mbits/sec  42.903 ms  16726/16761 (1e+02%)  
[  5]   2.01-3.02   sec   408 KBytes  3.29 Mbits/sec  20.992 ms  15643/15694 (1e+02%)  
[  5]   3.02-4.03   sec   392 KBytes  3.17 Mbits/sec  25.503 ms  15140/15189 (1e+02%)  
[  5]   4.03-5.02   sec   488 KBytes  4.07 Mbits/sec  11.793 ms  17642/17703 (1e+02%)  
[  5]   5.02-5.24   sec   128 KBytes  4.69 Mbits/sec  10.405 ms  2178/2194 (99%)  
- - - - - - - - - - - - - - - - - - - - - - - - -
[ ID] Interval           Transfer     Bandwidth       Jitter    Lost/Total Datagrams
[  5]   0.00-5.24   sec   571 MBytes   915 Mbits/sec  10.405 ms  72415/72673 (1e+02%)  


========= UDP reverse ($extra = -u -R) ============
Connecting to host sheevaplug, port 3740
Reverse mode, remote host sheevaplug is sending
[  4] local 192.168.0.139 port 48931 connected to 192.168.0.70 port 3740
[ ID] Interval           Transfer     Bandwidth       Jitter    Lost/Total Datagrams
[  4]   0.00-1.00   sec  55.0 MBytes   462 Mbits/sec  0.083 ms  320/7366 (4.3%)  
[  4]   1.00-2.00   sec  57.5 MBytes   482 Mbits/sec  0.132 ms  0/7362 (0%)  
[  4]   2.00-3.00   sec  57.0 MBytes   478 Mbits/sec  0.079 ms  0/7295 (0%)  
[  4]   3.00-4.00   sec  58.1 MBytes   488 Mbits/sec  0.088 ms  0/7439 (0%)  
[  4]   4.00-5.00   sec  58.2 MBytes   488 Mbits/sec  0.073 ms  0/7446 (0%)  
- - - - - - - - - - - - - - - - - - - - - - - - -
[ ID] Interval           Transfer     Bandwidth       Jitter    Lost/Total Datagrams
[  4]   0.00-5.00   sec   288 MBytes   484 Mbits/sec  0.079 ms  320/36920 (0.87%)  
[  4] Sent 36920 datagrams

iperf Done.

-----------------------------------------------------------
Server listening on 3740
-----------------------------------------------------------
Accepted connection from 192.168.0.139, port 45462
[  5] local 192.168.0.70 port 3740 connected to 192.168.0.139 port 48931
[ ID] Interval           Transfer     Bandwidth       Total Datagrams
[  5]   0.00-1.00   sec  55.7 MBytes   467 Mbits/sec  7130  
[  5]   1.00-2.00   sec  56.9 MBytes   477 Mbits/sec  7280  
[  5]   2.00-3.00   sec  57.0 MBytes   478 Mbits/sec  7290  
[  5]   3.00-4.00   sec  58.2 MBytes   488 Mbits/sec  7450  
[  5]   4.00-5.00   sec  58.1 MBytes   488 Mbits/sec  7440  
[  5]   5.00-5.05   sec  2.58 MBytes   483 Mbits/sec  330  
- - - - - - - - - - - - - - - - - - - - - - - - -
[ ID] Interval           Transfer     Bandwidth       Jitter    Lost/Total Datagrams
[  5]   0.00-5.05   sec   288 MBytes   479 Mbits/sec  0.079 ms  320/36920 (0.87%)  


========= TCP ($extra = ) ====================
Connecting to host sheevaplug, port 3740
[  4] local 192.168.0.139 port 45464 connected to 192.168.0.70 port 3740
[ ID] Interval           Transfer     Bandwidth       Retr  Cwnd
[  4]   0.00-1.00   sec  68.6 MBytes   575 Mbits/sec    0    361 KBytes       
[  4]   1.00-2.00   sec  79.6 MBytes   669 Mbits/sec    0    451 KBytes       
[  4]   2.00-3.00   sec  80.1 MBytes   672 Mbits/sec    0    451 KBytes       
[  4]   3.00-4.00   sec  80.8 MBytes   678 Mbits/sec    0    451 KBytes       
[  4]   4.00-5.00   sec  81.0 MBytes   678 Mbits/sec    0    451 KBytes       
- - - - - - - - - - - - - - - - - - - - - - - - -
[ ID] Interval           Transfer     Bandwidth       Retr
[  4]   0.00-5.00   sec   390 MBytes   654 Mbits/sec    0             sender
[  4]   0.00-5.00   sec   387 MBytes   649 Mbits/sec                  receiver

iperf Done.

-----------------------------------------------------------
Server listening on 3740
-----------------------------------------------------------
Accepted connection from 192.168.0.139, port 45463
[  5] local 192.168.0.70 port 3740 connected to 192.168.0.139 port 45464
[ ID] Interval           Transfer     Bandwidth
[  5]   0.00-1.00   sec  67.0 MBytes   561 Mbits/sec                  
[  5]   1.00-2.00   sec  77.0 MBytes   646 Mbits/sec                  
[  5]   2.00-3.00   sec  80.1 MBytes   671 Mbits/sec                  
[  5]   3.00-4.00   sec  80.8 MBytes   678 Mbits/sec                  
[  5]   4.00-5.00   sec  80.9 MBytes   679 Mbits/sec                  
[  5]   5.00-5.02   sec  1.00 MBytes   595 Mbits/sec                  
- - - - - - - - - - - - - - - - - - - - - - - - -
[ ID] Interval           Transfer     Bandwidth       Retr
[  5]   0.00-5.02   sec   390 MBytes   652 Mbits/sec    0             sender
[  5]   0.00-5.02   sec   387 MBytes   647 Mbits/sec                  receiver


========= TCP reverse ($extra = -R) ============
Connecting to host sheevaplug, port 3740
Reverse mode, remote host sheevaplug is sending
[  4] local 192.168.0.139 port 45466 connected to 192.168.0.70 port 3740
[ ID] Interval           Transfer     Bandwidth
[  4]   0.00-1.00   sec  72.2 MBytes   605 Mbits/sec                  
[  4]   1.00-2.00   sec  72.0 MBytes   604 Mbits/sec                  
[  4]   2.00-3.00   sec  72.2 MBytes   606 Mbits/sec                  
[  4]   3.00-4.00   sec  73.8 MBytes   619 Mbits/sec                  
[  4]   4.00-5.00   sec  73.5 MBytes   616 Mbits/sec                  
- - - - - - - - - - - - - - - - - - - - - - - - -
[ ID] Interval           Transfer     Bandwidth       Retr
[  4]   0.00-5.00   sec   364 MBytes   611 Mbits/sec    0             sender
[  4]   0.00-5.00   sec   364 MBytes   611 Mbits/sec                  receiver

iperf Done.

-----------------------------------------------------------
Server listening on 3740
-----------------------------------------------------------
Accepted connection from 192.168.0.139, port 45465
[  5] local 192.168.0.70 port 3740 connected to 192.168.0.139 port 45466
[ ID] Interval           Transfer     Bandwidth       Retr  Cwnd
[  5]   0.00-1.02   sec  73.0 MBytes   599 Mbits/sec    0    257 KBytes       
[  5]   1.02-2.03   sec  72.5 MBytes   604 Mbits/sec    0    257 KBytes       
[  5]   2.03-3.03   sec  72.5 MBytes   606 Mbits/sec    0    257 KBytes       
[  5]   3.03-4.03   sec  73.8 MBytes   619 Mbits/sec    0    257 KBytes       
[  5]   4.03-5.02   sec  72.5 MBytes   616 Mbits/sec    0    257 KBytes       
[  5]   5.02-5.02   sec  0.00 Bytes  0.00 bits/sec    0    257 KBytes       
- - - - - - - - - - - - - - - - - - - - - - - - -
[ ID] Interval           Transfer     Bandwidth       Retr
[  5]   0.00-5.02   sec   364 MBytes   609 Mbits/sec    0             sender
[  5]   0.00-5.02   sec   364 MBytes   609 Mbits/sec                  receiver
