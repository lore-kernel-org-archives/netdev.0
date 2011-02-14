From: Lukasz Trabinski <lukasz@trabinski.net>
Subject: net.ipv6.route.max_size
Date: Mon, 14 Feb 2011 21:39:55 +0100 (CET)
Message-ID: <alpine.LFD.2.00.1102142136520.10107@oceanic.wsisiz.edu.pl>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from oceanic.wsisiz.edu.pl ([213.135.44.33]:48407 "EHLO
	oceanic.wsisiz.edu.pl" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750949Ab1BNUqv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Feb 2011 15:46:51 -0500
Received: from localhost (localhost.localdomain [127.0.0.1])
	by oceanic.wsisiz.edu.pl (Postfix) with ESMTP id 678068412F
	for <netdev@vger.kernel.org>; Mon, 14 Feb 2011 21:40:21 +0100 (CET)
Received: from oceanic.wsisiz.edu.pl ([127.0.0.1])
	by localhost (oceanic.wsisiz.edu.pl [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id 1Hmoq3g2byTZ for <netdev@vger.kernel.org>;
	Mon, 14 Feb 2011 21:39:56 +0100 (CET)
Received: from localhost (localhost [127.0.0.1])
	by oceanic.wsisiz.edu.pl (Postfix) with ESMTP id AE29A8412F
	for <netdev@vger.kernel.org>; Mon, 14 Feb 2011 21:39:55 +0100 (CET)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello

IPv6 route table size is still growing. In stanard linux box configuration
with IPv6 BGP session (with ipv6 world table) and BGP application like Quagga,
we have problem like this:

2011/02/12 18:43:52 ZEBRA: netlink-cmd error: Cannot allocate memory,
type=RTM_NEWROUTE(24), seq=11124600, pid=0

This problem shows us that's all prefixes comes from BGP can't be install into 
FIB

IN BGP application we can see, that's we recive 4484 prefixes from ipv6 
neighbor:

cosmos> show bgp summary
Neighbor        V    AS MsgRcvd MsgSent   TblVer  InQ OutQ Up/Down State/PfxRcd
2001:1a68:0:c::1
                 4 24724  431945   70172        0    0    0 2d01h18m     4484


I suggest that net->ipv6.sysctl.ip6_rt_max_size should be increase.
Below _simple_ patch for this problem. I don't understand why in ipv4/route we 
have different method to count ip4_rt_max_size? My value 65536 in near future 
will be also wrong. I know also, that we can change it by sysctl, but I thing 
that it's not good way to fix it.


--- route.c~    2011-02-08 01:03:55.000000000 +0100
+++ route.c     2011-02-14 20:48:53.000000000 +0100
@@ -2708,7 +2708,7 @@
  #endif

         net->ipv6.sysctl.flush_delay = 0;
-       net->ipv6.sysctl.ip6_rt_max_size = 4096;
+       net->ipv6.sysctl.ip6_rt_max_size = 65536;
         net->ipv6.sysctl.ip6_rt_gc_min_interval = HZ / 2;
         net->ipv6.sysctl.ip6_rt_gc_timeout = 60*HZ;
         net->ipv6.sysctl.ip6_rt_gc_interval = 30*HZ;

