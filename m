From: Christoph Lameter <cl@linux-foundation.org>
Subject: Re: UDP multicast packet loss not reported if TX ring overrun?
Date: Mon, 17 Aug 2009 18:52:25 -0400 (EDT)
Message-ID: <alpine.DEB.1.10.0908171848370.15956@gentwo.org>
References: <alpine.DEB.1.10.0908171548040.20399@gentwo.org>  <4A89C026.4030402@us.ibm.com>  <alpine.DEB.1.10.0908171642500.20399@gentwo.org>  <1250545839.25939.21.camel@w-sridhar.beaverton.ibm.com>  <alpine.DEB.1.10.0908171813070.15956@gentwo.org>
 <1250549034.25939.30.camel@w-sridhar.beaverton.ibm.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Nivedita Singhvi <niv@us.ibm.com>, netdev@vger.kernel.org,
	Eric Dumazet <dada1@cosmosbay.com>
To: Sridhar Samudrala <sri@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp3.ultrahosting.com ([74.213.175.254]:41885 "EHLO
	smtp.ultrahosting.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1758200AbZHQWwe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Aug 2009 18:52:34 -0400
Received: from localhost (smtp.ultrahosting.com [127.0.0.1])
	by smtp.ultrahosting.com (Postfix) with ESMTP id ECBA382C4AA
	for <netdev@vger.kernel.org>; Mon, 17 Aug 2009 18:52:40 -0400 (EDT)
Received: from smtp.ultrahosting.com ([74.213.175.254])
	by localhost (smtp.ultrahosting.com [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id 6U0IxQATBJUp for <netdev@vger.kernel.org>;
	Mon, 17 Aug 2009 18:52:36 -0400 (EDT)
Received: from gentwo.org (unknown [74.213.171.31])
	by smtp.ultrahosting.com (Postfix) with ESMTP id B9C3382C5B6
	for <netdev@vger.kernel.org>; Mon, 17 Aug 2009 18:52:34 -0400 (EDT)
In-Reply-To: <1250549034.25939.30.camel@w-sridhar.beaverton.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 17 Aug 2009, Sridhar Samudrala wrote:

> On Mon, 2009-08-17 at 18:13 -0400, Christoph Lameter wrote:
> > On Mon, 17 Aug 2009, Sridhar Samudrala wrote:
> >
> > > What about ethtool -S ? Does it report any errors?
> >
> > Neither. This is is a broadcom bnx2 NIC.
>
> Are you sure the packets are dropped at the sender?

Yes I am sending 400k messages from the app and the receiver only gets
341k @300 byte (which is the line rate). There is no way that the 400k get
over the line. Also if I reduce SO_SNDBUF then both receiver and
sender get down to 341k.

I added the output of ethtool -S at the end.

The mcast tool can be had from http://gentwo.org/ll or from my directory
on www.kernel.org.

> Another place where packet drops/errors are counted is
>     /proc/net/softnet_stat
> It tracks some counters that could result in drops. I thought these are
> all receive statistics. But looks like cpu_collision is a tx stat. The
> name of the structure is netif_rx_stat and it includes cpu_collison
> counter.

How do I decode that information?


clameter@rd-gateway3:~$ cat /proc/net/softnet_stat
00000a2f 00000000 00000000 00000000 00000000 00000000 00000000 00000000
00000000
00000000 00000000 00000000 00000000 00000000 00000000 00000000 00000000
00000000
00000000 00000000 00000000 00000000 00000000 00000000 00000000 00000000
00000000
00000000 00000000 00000000 00000000 00000000 00000000 00000000 00000000
00000000
00000000 00000000 00000000 00000000 00000000 00000000 00000000 00000000
00000000
00000000 00000000 00000000 00000000 00000000 00000000 00000000 00000000
00000000
00000000 00000000 00000000 00000000 00000000 00000000 00000000 00000000
00000000
00000000 00000000 00000000 00000000 00000000 00000000 00000000 00000000
00000000
00000000 00000000 00000000 00000000 00000000 00000000 00000000 00000000
00000000
00000000 00000000 00000000 00000000 00000000 00000000 00000000 00000000
00000000
00000000 00000000 00000000 00000000 00000000 00000000 00000000 00000000
00000000
0000000c 00000000 00000000 00000000 00000000 00000000 00000000 00000000
00000000
00000000 00000000 00000000 00000000 00000000 00000000 00000000 00000000
00000000
00000018 00000000 00000000 00000000 00000000 00000000 00000000 00000000
00000000
00000000 00000000 00000000 00000000 00000000 00000000 00000000 00000000
00000000
00000006 00000000 00000000 00000000 00000000 00000000 00000000 00000000
00000000

rd-gateway3:/home/clameter# ethtool -S eth0
NIC statistics:
     rx_bytes: 380526
     rx_error_bytes: 0
     tx_bytes: 6299438984
     tx_error_bytes: 0
     rx_ucast_packets: 2373
     rx_mcast_packets: 168
     rx_bcast_packets: 5
     tx_ucast_packets: 1972
     tx_mcast_packets: 18205522
     tx_bcast_packets: 0
     tx_mac_errors: 0
     tx_carrier_errors: 0
     rx_crc_errors: 0
     rx_align_errors: 0
     tx_single_collisions: 0
     tx_multi_collisions: 0
     tx_deferred: 0
     tx_excess_collisions: 0
     tx_late_collisions: 0
     tx_total_collisions: 0
     rx_fragments: 0
     rx_jabbers: 0
     rx_undersize_packets: 0
     rx_oversize_packets: 0
     rx_64_byte_packets: 375
     rx_65_to_127_byte_packets: 1857
     rx_128_to_255_byte_packets: 168
     rx_256_to_511_byte_packets: 39
     rx_512_to_1023_byte_packets: 12
     rx_1024_to_1522_byte_packets: 95
     rx_1523_to_9022_byte_packets: 0
     tx_64_byte_packets: 221
     tx_65_to_127_byte_packets: 1413
     tx_128_to_255_byte_packets: 240
     tx_256_to_511_byte_packets: 18205519
     tx_512_to_1023_byte_packets: 18
     tx_1024_to_1522_byte_packets: 83
     tx_1523_to_9022_byte_packets: 0
     rx_xon_frames: 0
     rx_xoff_frames: 0
     tx_xon_frames: 0
     tx_xoff_frames: 0
     rx_mac_ctrl_frames: 0
     rx_filtered_packets: 16002
     rx_discards: 0
     rx_fw_discards: 0

