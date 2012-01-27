From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/2] ipv4/ipv6: Prepare for new route gateway semantics.
Date: Fri, 27 Jan 2012 16:34:00 -0500 (EST)
Message-ID: <20120127.163400.1656316431173173490.davem@davemloft.net>
References: <20120126.155544.2054995753871805122.davem@davemloft.net>
	<201201271259.51534.bcook@breakingpoint.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: bcook@breakingpoint.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:45946 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751549Ab2A0VeE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Jan 2012 16:34:04 -0500
In-Reply-To: <201201271259.51534.bcook@breakingpoint.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Brent Cook <bcook@breakingpoint.com>
Date: Fri, 27 Jan 2012 12:59:51 -0600

> On Thursday, January 26, 2012 02:55:44 PM David Miller wrote:
>> In the future the ipv4/ipv6 route gateway will take on two types
>> of values:
>> 
>> 1) INADDR_ANY/IN6ADDR_ANY, for local network routes, and in this case
>>    the neighbour must be obtained using the destination address in
>>    ipv4/ipv6 header as the lookup key.
>> 
>> 2) Everything else, the actual nexthop route address.
>> 
>> So if the gateway is not inaddr-any we use it, otherwise we must use
>> the packet's destination address.
> 
> Under what cases would this be expected to help keep the # of lookup keys at a 
> minimum?

The point is to accomodate the future wherein a single route might cover
an entire subnet's worth of destinations.

I am going to remove the routing cache, and route lookups will use the
routing table entries directly.

In order to accomodate that two thing have to happen:

1) Neighbour entires cannot be referred to by the routes, they must be
   looked up as-needed.  This is because a neighbour refers to a specific
   single nexthop, whereas routes in the future will refer potentially
   to many nexthops.

2) Routes must also not refer directly to inetpeer entries, this is also
   because routes will refer to potentially several destinations whereas
   inetpeer entries only apply to specific destinations.
