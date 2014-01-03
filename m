From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] macvlan: fix oops with vlan-on-top and HW_VLAN_CTAG_TX
 lowerdev
Date: Fri, 03 Jan 2014 15:33:52 -0500 (EST)
Message-ID: <20140103.153352.166630160016412696.davem@davemloft.net>
References: <20131230102712.GO29632@breakpoint.cc>
	<20131231.162448.1656983197554902144.davem@davemloft.net>
	<20140103113904.GB28854@breakpoint.cc>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: fw@strlen.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:34117 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753064AbaACUdz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 3 Jan 2014 15:33:55 -0500
In-Reply-To: <20140103113904.GB28854@breakpoint.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Westphal <fw@strlen.de>
Date: Fri, 3 Jan 2014 12:39:04 +0100

>> +static const struct header_ops vlan_passthru_header_ops = {
>> +	.create	 = vlan_passthru_hard_header,
>> +	.rebuild = dev_rebuild_header,
> 
> Doesn't that result in infinite recursion when invoking
> dev_rebuild_header() on skb whose dev->header_ops is
> vlan_passthru_header_ops?

The skb->dev should be the real_dev at this point, no?
