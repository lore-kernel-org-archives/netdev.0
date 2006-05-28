From: Aravind Gottipati <aravind@freeshell.org>
Subject: Re: e1000 poor network performance - 2.6.17-rc5-g705af309
Date: Sun, 28 May 2006 07:43:10 +0000
Message-ID: <20060528074310.GA16499@SDF.LONESTAR.ORG>
References: <20060526212243.GA19250@SDF.LONESTAR.ORG> <4807377b0605271410j39532f44j2cafd3239d40bf31@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx.freeshell.ORG ([192.94.73.18]:42989 "EHLO sdf.lonestar.org")
	by vger.kernel.org with ESMTP id S932084AbWE1HnM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 28 May 2006 03:43:12 -0400
Received: from sdf.lonestar.org (IDENT:aravind@otaku.freeshell.org [192.94.73.2])
	by sdf.lonestar.org (8.13.5.20060308/8.12.10) with ESMTP id k4S7hBKU022318
	for <netdev@vger.kernel.org>; Sun, 28 May 2006 07:43:11 GMT
Received: (from aravind@localhost)
	by sdf.lonestar.org (8.13.5.20060308/8.12.8/Submit) id k4S7hA0P026215
	for netdev@vger.kernel.org; Sun, 28 May 2006 07:43:10 GMT
To: netdev@vger.kernel.org
Content-Disposition: inline
In-Reply-To: <4807377b0605271410j39532f44j2cafd3239d40bf31@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, May 27, 2006 at 02:10:17PM -0700, Jesse Brandeburg wrote:
> What kind of poor performance?  what test? please send the output of
> ethtool -e ethX and ethtool -S ethX after you've been having problems.

I first noticed the problem (slow speed) when pinging sites.  I then
noticed that the problem occured on normal ssh sessions and ftp/http
downloads as well.  I have a spare pcmcia card that I am using on the
same laptop so I have something to compare it against.  In all the
readings below, eth0 is the builtin Intel 82573L (PCI-Express) card and
eth2 is a pcmcia D-link card (8139too driver).

You can see below the ping times varying randomly through eth0.  Compare
these with the ping times through eth2 (at the bottom).  Also there are
some collisions in the ethtool -S output here (I am on a 10/100 hub),  I
see the same performance using a switch as well.

I am not subscribed to the list, so please cc me on your responses.

Thank you,

Aravind.

-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
ping via eth0

root@dogmatrix:~# ping www.google.com
PING www.l.google.com (66.102.7.99): 56 data bytes
64 bytes from 66.102.7.99: icmp_seq=0 ttl=239 time=135.0 ms
64 bytes from 66.102.7.99: icmp_seq=1 ttl=239 time=601.3 ms
64 bytes from 66.102.7.99: icmp_seq=2 ttl=239 time=133.2 ms
64 bytes from 66.102.7.99: icmp_seq=3 ttl=239 time=904.8 ms
64 bytes from 66.102.7.99: icmp_seq=4 ttl=239 time=131.3 ms
64 bytes from 66.102.7.99: icmp_seq=5 ttl=239 time=1001.3 ms
64 bytes from 66.102.7.99: icmp_seq=6 ttl=239 time=129.4 ms
64 bytes from 66.102.7.99: icmp_seq=7 ttl=239 time=1001.5 ms
64 bytes from 66.102.7.99: icmp_seq=8 ttl=239 time=127.5 ms
64 bytes from 66.102.7.99: icmp_seq=9 ttl=239 time=1001.0 ms
64 bytes from 66.102.7.99: icmp_seq=10 ttl=239 time=125.2 ms
64 bytes from 66.102.7.99: icmp_seq=11 ttl=239 time=19.8 ms
64 bytes from 66.102.7.99: icmp_seq=12 ttl=239 time=123.2 ms
64 bytes from 66.102.7.99: icmp_seq=13 ttl=239 time=1001.3 ms
64 bytes from 66.102.7.99: icmp_seq=14 ttl=239 time=121.4 ms
64 bytes from 66.102.7.99: icmp_seq=15 ttl=239 time=1001.4 ms
64 bytes from 66.102.7.99: icmp_seq=16 ttl=239 time=119.5 ms

--- www.l.google.com ping statistics ---
17 packets transmitted, 17 packets received, 0% packet loss
round-trip min/avg/max = 19.8/451.6/1001.5 ms

-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=

root@dogmatrix:~# ethtool -e eth0
Offset          Values
------          ------
0x0000          00 0a e4 3f a5 da 30 0b b2 ff 51 00 ff ff ff ff 
0x0010          53 00 03 02 6b 02 7e 20 aa 17 9a 10 86 80 df 80 
0x0020          00 00 00 20 54 7e 00 00 14 00 da 00 04 00 00 27 
0x0030          c9 6c 50 31 3e 07 0b 04 8b 29 00 00 00 f0 02 0f 
0x0040          08 10 00 00 04 0f ff 7f 01 4d ff ff ff ff ff ff 
0x0050          14 00 1d 00 14 00 1d 00 af aa 1e 00 00 00 1d 00 
0x0060          00 01 00 40 1f 12 07 40 ff ff ff ff ff ff ff ff 
0x0070          ff ff ff ff ff ff ff ff ff ff ff ff ff ff 73 79 

root@dogmatrix:~# ethtool -S eth0
NIC statistics:
     rx_packets: 1757
     tx_packets: 1995
     rx_bytes: 657421
     tx_bytes: 228828
     rx_errors: 0
     tx_errors: 0
     tx_dropped: 0
     multicast: 0
     collisions: 13
     rx_length_errors: 0
     rx_over_errors: 0
     rx_crc_errors: 0
     rx_frame_errors: 0
     rx_no_buffer_count: 0
     rx_missed_errors: 0
     tx_aborted_errors: 0
     tx_carrier_errors: 0
     tx_fifo_errors: 0
     tx_heartbeat_errors: 0
     tx_window_errors: 0
     tx_abort_late_coll: 0
     tx_deferred_ok: 27
     tx_single_coll_ok: 2
     tx_multi_coll_ok: 5
     tx_timeout_count: 0
     rx_long_length_errors: 0
     rx_short_length_errors: 0
     rx_align_errors: 0
     tx_tcp_seg_good: 0
     tx_tcp_seg_failed: 0
     rx_flow_control_xon: 0
     rx_flow_control_xoff: 0
     tx_flow_control_xon: 0
     tx_flow_control_xoff: 0
     rx_long_byte_count: 657421
     rx_csum_offload_good: 1709
     rx_csum_offload_errors: 0
     rx_header_split: 1433
     alloc_rx_buff_failed: 0
root@dogmatrix:~# 

-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
The same ping using eth2

root@dogmatrix:~# ping www.google.com
PING www.l.google.com (66.102.7.99): 56 data bytes
64 bytes from 66.102.7.99: icmp_seq=0 ttl=239 time=16.3 ms
64 bytes from 66.102.7.99: icmp_seq=1 ttl=239 time=15.2 ms
64 bytes from 66.102.7.99: icmp_seq=2 ttl=239 time=14.8 ms
64 bytes from 66.102.7.99: icmp_seq=3 ttl=239 time=15.1 ms
64 bytes from 66.102.7.99: icmp_seq=4 ttl=239 time=16.6 ms
64 bytes from 66.102.7.99: icmp_seq=5 ttl=239 time=15.8 ms
64 bytes from 66.102.7.99: icmp_seq=6 ttl=239 time=14.9 ms
64 bytes from 66.102.7.99: icmp_seq=7 ttl=239 time=14.7 ms
64 bytes from 66.102.7.99: icmp_seq=8 ttl=239 time=14.6 ms

--- www.l.google.com ping statistics ---
9 packets transmitted, 9 packets received, 0% packet loss
round-trip min/avg/max = 14.6/15.3/16.6 ms

