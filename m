From: Tore Anderson <tore@linpro.no>
Subject: Multipath routing in Linux 2.6
Date: Tue, 06 Mar 2007 21:36:51 +0100
Message-ID: <45EDD0E3.3000906@linpro.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailhub.linpro.no ([213.236.139.167]:34874 "EHLO
	mailhub.linpro.no" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932212AbXCFVFs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Mar 2007 16:05:48 -0500
Received: from localhost (mailhub.linpro.no [213.236.139.167])
	by mailhub.linpro.no (Postfix) with ESMTP id 80F0F20043D
	for <netdev@vger.kernel.org>; Tue,  6 Mar 2007 21:36:51 +0100 (CET)
Received: from mailhub.linpro.no ([213.236.139.167])
	by localhost (mailhub.linpro.no [213.236.139.167]) (amavisd-new, port 10024)
	with ESMTP id 7OQ7V1-Vxajd for <netdev@vger.kernel.org>;
	Tue,  6 Mar 2007 21:36:51 +0100 (CET)
Received: from ox.linpro.no (ox.linpro.no [87.238.45.114])
	by mailhub.linpro.no (Postfix) with ESMTP
	for <netdev@vger.kernel.org>; Tue,  6 Mar 2007 21:36:51 +0100 (CET)
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


   Hello list,

   I've been trying to figure out how to make equal-cost multipath
  routing work, with no luck.  Asked on the LARTC list with no success,
  and attempts to contact the two authors privately yielded one bounce
  while the other declined to answer in private and pointed me to this
  list.  So I'll just include the rest of the mail I sent them here
  (after doing a search-and-replace on the first three octets of all
  addresses, I'm a bit paranoid), hopefully someone has some suggestions
  for me...

   I'm using 2.6.20 on an x86_64 machine.  I'm adding my route thusly:

     ip route add table 100 default \
       nexthop via 1.1.1.1 nexthop via 1.1.1.9

   It shows correctly up in the routing table:

     root@router:~# ip route show table 100
     default
             nexthop via 1.1.1.1  dev vlan11 weight 1
             nexthop via 1.1.1.9  dev vlan12 weight 1
     [...]

   I'm sending traffic from a relatively busy network to this table:

     root@router:~# ip rule
     [...]
     21000:  from 1.1.2.128/26 lookup 100
     [...]

   I can verify with tcpdump that the rule works correctly and that the
  route is used.  However, the traffic is without exception routed via
  1.1.1.9, not a single packet is sent to 1.1.1.1.  If I however swap
  the two nexthops while adding the route, all traffic is sent to
  1.1.1.1, and nothing ends up at 1.1.1.9.

   I've tried loading and unloading the multipath_{wrandom,rr,random,drr}
  modules, removing and readding the route, and flushing the routing
  cache.  Several times and in different order.  Nothing affects the
  behaviour though, all of the traffic is sent to the router specified as
  the second nexthop on the "ip route add" command line.

   I feel I'm missing something essential here but I have no idea what.
  Google only tells me about others having roughly the same problem but
  never any solution.  Do you have any suggestions for me?  If I can make
  this work I will be happy to document how and try to have that included
  in the next kernel/iproute release and hopefully nobody will bother you
  about it again.

   Thanks for your time!

Kind regards
-- 
Tore Anderson
