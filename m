From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] ipv4: introduce new IP_MTU_DISCOVER mode
 IP_PMTUDISC_INTERFACE
Date: Tue, 29 Oct 2013 00:08:44 -0400 (EDT)
Message-ID: <20131029.000844.1092862708536984032.davem@davemloft.net>
References: <20131026201158.GI15744@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, fweimer@redhat.com
To: hannes@stressinduktion.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:40344 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750719Ab3J2EIp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Oct 2013 00:08:45 -0400
In-Reply-To: <20131026201158.GI15744@order.stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Date: Sat, 26 Oct 2013 22:11:58 +0200

> Sockets marked with IP_PMTUDISC_INTERFACE won't do path mtu discovery,
> their sockets won't accept and install new path mtu information and they
> will always use the interface mtu for outgoing packets. It is guaranteed
> that the packet is not fragmented locally. But we won't set the DF-Flag
> on the outgoing frames.
> 
> Florian Weimer had the idea to use this flag to ensure DNS servers are
> never generating outgoing fragments. They may well be fragmented on the
> path, but the server never stores or usees path mtu values, which could
> well be forged in an attack.
> 
> (The root of the problem with path MTU discovery is that there is
> no reliable way to authenticate ICMP Fragmentation Needed But DF Set
> messages because they are sent from intermediate routers with their
> source addresses, and the IMCP payload will not always contain sufficient
> information to identify a flow.)

I do not like this reasoning.  You have several more acceptable paths to take
to resolve this problem:

1) "I don't trust path MTU information at all"

   Just turn it off globally, end of story.  It has the same effect as your
   new per-application mode.

2) "I don't trust path MTU information unless the full socket ID is available
    in the ICMP packets quoted headers"

   Then simply implement a policy as such and submit it to me.
