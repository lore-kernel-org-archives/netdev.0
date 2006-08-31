From: "Gary Chan" <hpchan5@ie.cuhk.edu.hk>
Subject: Linux UDP Implementation
Date: Thu, 31 Aug 2006 13:56:50 +0800
Message-ID: <00f401c6ccc2$40ad2a90$193aa8c0@mclabhpchan5>
Mime-Version: 1.0
Content-Type: text/plain;
	format=flowed;
	charset="ISO-8859-1";
	reply-type=original
Content-Transfer-Encoding: 7bit
Return-path: <netdev-owner@vger.kernel.org>
Received: from eng.ie.cuhk.edu.hk ([137.189.96.20]:57030 "EHLO
	eng.ie.cuhk.edu.hk") by vger.kernel.org with ESMTP id S1750733AbWHaF4w
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 31 Aug 2006 01:56:52 -0400
Received: from viruswall2.ie.cuhk.edu.hk (IDENT:U2FsdGVkX1/DKcu35zfNFXSHN5zbjh3NlKx6RMIPDgU@viruswall2 [137.189.96.53])
	by eng.ie.cuhk.edu.hk (8.13.6/8.13.6) with ESMTP id k7V5uoAN003714
	for <netdev@vger.kernel.org>; Thu, 31 Aug 2006 13:56:50 +0800
Received: from mclabhpchan5 (iegatea1 [137.189.98.1])
	by viruswall2.ie.cuhk.edu.hk (8.13.6/8.13.6) with SMTP id k7V5uoYh030084
	for <netdev@vger.kernel.org>; Thu, 31 Aug 2006 13:56:50 +0800
To: <netdev@vger.kernel.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

According to the function call udp_sendmsg() in the source file 
net/ipv4/udp.c (Linux Kernel 2.6.17.11), when an error value is returned 
from the function ip_append_data() due to local device congestion, say 
interface queue overflow,  pending packets in the queue sk->sk_write_queue 
are simply flushed (udp_flush_pending_frames() is invoked) without caching 
for future retransmission.

I called a network API function sendto() to transmit UDP packets in a 
blocking I/O mode at a rate of 100Mbps over the 802.11b wireless ad hoc 
network, the network was overloaded as the maximum transfer rate for 802.11b 
was just 11Mbps. Therefore, the outgoing interface queue must be full and 
UDP packets will be dropped eventually. However, I checked that there was no 
packet loss at the receiver side, i.e. the number of packets sent from the 
sender is equal to that received.

It seems that the implementation (at code level) does not match with the 
actual behaviour. I would like to seek expertise on clarifying my 
understanding in UDP implementation so that this phenomenon can be 
explained.

Thank you. 

