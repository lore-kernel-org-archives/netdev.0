From: ebiederm@xmission.com (Eric W. Biederman)
Subject: echo > 0 .../disable_ipv6 broken in 2.6.37-rc4
Date: Sun, 05 Dec 2010 16:24:22 -0800
Message-ID: <m17hfnlpe1.fsf@fess.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Brian Haley <brian.haley@hp.com>,
	Mahesh Kelkar <maheshkelkar@gmail.com>,
	Lorenzo Colitti <lorenzo@google.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out01.mta.xmission.com ([166.70.13.231]:35236 "EHLO
	out01.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752224Ab0LFBIb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 5 Dec 2010 20:08:31 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


In 2.6.37-rc4 ipv6 can be disabled not enabled.
The last kernel I have tested and know this works on is 2.6.33.

To reproduce:
   ~ # ip link set lo up
   ~ # ping6 ::1
   PING ::1(::1) 56 data bytes
   64 bytes from ::1: icmp_seq=1 ttl=64 time=0.026 ms
   ^C
   --- ::1 ping statistics ---
   1 packets transmitted, 1 received, 0% packet loss, time 782ms
   rtt min/avg/max/mdev = 0.026/0.026/0.026/0.000 ms
   ~ # echo 1 > /proc/sys/net/ipv6/conf/lo/disable_ipv6 
   ~ # ping6 ::1
   connect: Network is unreachable
   ~ # echo 0 > /proc/sys/net/ipv6/conf/lo/disable_ipv6 
   ~ # ping6 ::1
   connect: Network is unreachable


I intend to poke at this a little more but at the moment
I am drawing a blank at what is going on.

I have tried reverting the last change to the ipv6 logic
and that doesn't make a difference.

   commit 64e724f62ab743d55229cd5e27ec8b068b68eb16
   Author: Brian Haley <brian.haley@hp.com>
   Date:   Tue Jul 20 10:34:30 2010 +0000
   
       ipv6: Don't add routes to ipv6 disabled interfaces.
       
       If the interface has IPv6 disabled, don't add a multicast or
       link-local route since we won't be adding a link-local address.
       
       Reported-by: Mahesh Kelkar <maheshkelkar@gmail.com>
       Signed-off-by: Brian Haley <brian.haley@hp.com>
       Signed-off-by: David S. Miller <davem@davemloft.net>

I intend to keep poking at this but if anyone can figure this out
before I do I would be greatly appreciative.

Eric


