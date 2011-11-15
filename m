From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ipv4: fix for ip_options_rcv_srr() daddr update.
Date: Tue, 15 Nov 2011 03:23:43 -0500 (EST)
Message-ID: <20111115.032343.1203870624086709786.davem@davemloft.net>
References: <4EC21427.9080008@cn.fujitsu.com>
	<20111115.022835.551127337110017182.davem@davemloft.net>
	<4EC21A01.90702@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: lw@cn.fujitsu.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:53994 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752521Ab1KOIXw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Nov 2011 03:23:52 -0500
In-Reply-To: <4EC21A01.90702@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Li Wei <lw@cn.fujitsu.com>
Date: Tue, 15 Nov 2011 15:51:29 +0800

>> From: Li Wei <lw@cn.fujitsu.com>
>> Date: Tue, 15 Nov 2011 15:26:31 +0800
>> 
>>> My question, in ip_forward() and ip_forward_options() rt is there, why not
>>> we just use it?
>> 
>> Because I'm trying to eliminate all accesses to rt->rt_dst because
>> when I remove the routing cache, routes will be shared.  One 'rt'
>> will refer to many specific destination addresses.
>> 
>> 
> Sorry, I can't understand what you said, can you make it more clear?
> 
> I think in ip_forward(), we need 'rt' to forward skb, until this skb has been 
> forwarded we hold a reference to it in skb, We can use rt->rt_dst safely, It
> is an ordinary __be32 not a reference.

My long term plan is to eliminate cached routes, we will directly use
routing table entries instead.

In such a scheme, the member rt->rt_dst will no longer even exist.

This is what I've been working towards for more than a year, it is a
slow and very difficult transformation.

If you starting adding rt->rt_dst references back, we are taking
steps backwards.
