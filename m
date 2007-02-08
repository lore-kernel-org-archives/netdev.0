From: Eric Dumazet <dada1@cosmosbay.com>
Subject: [PATCH 0/5] NET Improve layering of structs dst_entry/rtable/rt6_info/dn_route
 to get less dcache footprint
Date: Thu, 08 Feb 2007 22:32:10 +0100
Message-ID: <45CB96DA.20400@cosmosbay.com>
References: <20070208093935.90CA.SHINTA@sfc.wide.ad.jp> <20070207.165213.98418769.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([86.65.150.130]:54103 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1423428AbXBHVca (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Feb 2007 16:32:30 -0500
In-Reply-To: <20070207.165213.98418769.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi David

Large routers/servers spend lot of CPU time in route cache lookups. This is 
because each item lookup uses two cache lines : the next pointer is at the 
begining of item, but keys are far away from this pointer.

Furthermore, the u unions declared in struct rtable, rt6_info and dn_route are 
imho quite ugly (forcing next pointer be at null offset)

This patch try to cleanup the layering and try to put the 'next' pointer near 
the fields used at lookup time (in ip_route_input() for example)

I prepared the following five patches :

[PATCH 1/5] : Introduce union in struct dst_entry, to prepare patches 2,3,4
[PATCH 2/5] : Convert ipv4 route to use the new dst_entry 'next' pointer
[PATCH 3/5] : Convert ipv6 route to use the new dst_entry 'next' pointer
[PATCH 4/5] : Convert decnet route to use the new dst_entry 'next' pointer
[PATCH 5/5] : Reorder fields of struct dst_entry

Thank you
Eric Dumazet
