From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] fib_trie: Send RTM_DELROUTE when link goes
 down
Date: Thu, 17 Oct 2013 16:19:09 -0400 (EDT)
Message-ID: <20131017.161909.251791393805386332.davem@davemloft.net>
References: <CAKfDRXizw1TaK-oHrAQv8Hi80gKiUHjQ6d21o3MOQpuVkcXSow@mail.gmail.com>
	<1382028894-14236-1-git-send-email-kristian.evensen@gmail.com>
	<alpine.LFD.2.03.1310172245440.2016@ssi.bg>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kristian.evensen@gmail.com, netdev@vger.kernel.org
To: ja@ssi.bg
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:46933 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758649Ab3JQUTL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Oct 2013 16:19:11 -0400
In-Reply-To: <alpine.LFD.2.03.1310172245440.2016@ssi.bg>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Julian Anastasov <ja@ssi.bg>
Date: Thu, 17 Oct 2013 22:52:43 +0300 (EEST)

> 
> 	Hello,
> 
> On Thu, 17 Oct 2013, Kristian Evensen wrote:
> 
>> From: Kristian Evensen <kristian.evensen@gmail.com>
>> 
>> When a link is set as down using for example "ip link set dev X down", routes
>> are deleted, but RTM_DELROUTE messages are not sent to RTNLGRP_IPV4_ROUTE. This
>> patch makes trie_flush_list() send a RTM_DELROUTE for each route that is
>> removed, and makes rtnelink route deletion behavior consistent across commands.
>> The parameter lists for trie_flush_list() and trie_flush_leaf() are expanded to
>> include required information otherwise unavailable in trie_flush_list().
>> 
>> One use case that is simplified by this patch is IPv4 WAN connection monitoring.
>> Instead of listening for and handling both RTM_*ROUTE and RTM_*LINK-messages, it
>> is sufficient to handle RTM_*ROUTE.
> 
> 	IIRC, such notifications were not implemented
> to avoid storms to routing daemons. Not sure if this is
> still true.

I'm definitely not applying this patch.

Routing daemons maintain the routing table internally, and they
therefore can purge their internal data structures when the link
down event occurs.

This is how it has worked forever and for real BGP tables the
RTM_DELROUTE traffic would be enormous and at nearly DoS levels
for anyone listening for them.
