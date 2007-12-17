From: Patrick McHardy <kaber@trash.net>
Subject: Re: "ip neigh show" not showing arp cache entries?
Date: Mon, 17 Dec 2007 19:02:05 +0100
Message-ID: <4766B99D.8060408@trash.net>
References: <4760279E.1080203@nortel.com>	<47602DD0.8070402@cosmosbay.com> <47605934.2060604@nortel.com> <20071213.070641.20411400.yoshfuji@linux-ipv6.org> <476696A5.1010101@nortel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: yoshfuji@linux-ipv6.org, dada1@cosmosbay.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Chris Friesen <cfriesen@nortel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:64215 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751388AbXLQSCz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Dec 2007 13:02:55 -0500
In-Reply-To: <476696A5.1010101@nortel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Chris Friesen wrote:
> The original "ip" command and the new one ("/tmp/ip") both give the same 
> results--some of the entries are missing.
> 
> root@typhoon-base-unit0:/root> ip neigh show all
> 172.24.137.0 dev bond0  FAILED
> 172.24.0.9 dev bond0 lladdr 00:07:e9:41:4b:b4 REACHABLE
> 10.41.18.101 dev eth6 lladdr 00:0e:0c:5e:95:bd REACHABLE
> 172.24.0.11 dev bond0 lladdr 00:03:cc:51:06:5e STALE
> 172.24.132.1 dev bond0 lladdr 00:01:af:14:e9:88 REACHABLE
> 172.24.0.15 dev bond0 lladdr 00:0e:0c:85:fd:d2 STALE
> 172.24.0.3 dev bond0 lladdr 00:01:af:14:c8:cc REACHABLE
> 172.24.0.5 dev bond0 lladdr 00:01:af:15:e0:6a STALE
> 
> root@typhoon-base-unit0:/root> /tmp/ip neigh show all
> 172.24.137.0 dev bond0  FAILED
> 172.24.0.9 dev bond0 lladdr 00:07:e9:41:4b:b4 REACHABLE
> 10.41.18.101 dev eth6 lladdr 00:0e:0c:5e:95:bd REACHABLE
> 172.24.0.11 dev bond0 lladdr 00:03:cc:51:06:5e STALE
> 172.24.132.1 dev bond0 lladdr 00:01:af:14:e9:88 REACHABLE
> 172.24.0.15 dev bond0 lladdr 00:0e:0c:85:fd:d2 STALE
> 172.24.0.3 dev bond0 lladdr 00:01:af:14:c8:cc REACHABLE
> 172.24.0.5 dev bond0 lladdr 00:01:af:15:e0:6a STALE
> 
> 
> However, if I specifically try to print out one of the missing entries, 
> it shows up:
> 
> root@typhoon-base-unit0:/root> /tmp/ip neigh show 192.168.24.81
> 192.168.24.81 dev bond2 lladdr 00:01:af:14:e9:8a REACHABLE


 From a kernel perspective there are only complete dumps, the
filtering is done by iproute. So the fact that it shows them
when querying specifically implies there is a bug in the
iproute neighbour filter. Does it work if you omit "all"
from the ip neigh show command?
