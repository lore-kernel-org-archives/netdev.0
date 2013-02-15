From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ipv4: Disallow non-namespace aware protocols to
 register.
Date: Fri, 15 Feb 2013 13:41:36 -0500 (EST)
Message-ID: <20130215.134136.798843717749865061.davem@davemloft.net>
References: <20130205.144302.2065386693901345213.davem@davemloft.net>
	<87pq028561.fsf@xmission.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: ebiederm@xmission.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:43420 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750832Ab3BOSlk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 Feb 2013 13:41:40 -0500
In-Reply-To: <87pq028561.fsf@xmission.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: ebiederm@xmission.com (Eric W. Biederman)
Date: Thu, 14 Feb 2013 22:25:26 -0800

> David Miller <davem@davemloft.net> writes:
> 
>> All in-tree ipv4 protocol implementations are now namespace
>> aware.  Therefore all the run-time checks are superfluous.
>>
>> Reject registry of any non-namespace aware ipv4 protocol.
>> Eventually we'll remove prot->netns_ok and this registry
>> time check as well.
> 
> It has been a long time coming but this is very cool to see we have
> finally made all of ipv4 network namespace aware.

BTW, I took a look at ipv6 and unlike ipv4 there seems to be no sanity
checks or per-protocol booleans indicating proper netns support.

Is my interpretation right that ipv6 just assumes all registered
protocols are netns aware at this point?

If so that was definitely a bug, because things like l2tp have an
ipv6 component and were not fully netns aware until very recently.
