From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH RFC] IPv6: RTM_GETROUTE NLM_F_MATCH handled as stated
 in RFC 3549
Date: Tue, 03 Jan 2012 15:16:19 -0500 (EST)
Message-ID: <20120103.151619.1382800390097680631.davem@davemloft.net>
References: <1325080915.26559.43.camel@hakki>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: matti.vaittinen@nsn.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:42405 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754848Ab2ACUQZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Jan 2012 15:16:25 -0500
In-Reply-To: <1325080915.26559.43.camel@hakki>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Matti Vaittinen <matti.vaittinen@nsn.com>
Date: Wed, 28 Dec 2011 16:01:55 +0200

> This patch makes ipv6 module to return only routes which match 
> attributes / filled fields in RTM_GETROUTE, if NLM_F_MATCH is 
> specified and NLM_F_ROOT is not. This patch has not been tested, 
> and is meant more to be for visualization of what I thought of doing.
> If the NLM_F_MATCH support is considered to be good idea, then I 
> will check this more thoroughly and send another patch.
> 
> I assume this would not break *many* existing userspace applications, 
> since specifying NLM_F_MATCH (especially with no NLM_F_ROOT) sounds 
> pretty stupid - if no entries should be filtered.
> 
> I checked iproute2, and it uses NLM_F_DUMP and does filtering entries 
> in userspace - thus it is not affected. 
> 
> I guess this same idea could be brought in RTM_GETADDR and RTM_GETLINK 
> too? Maybe also on IPv4 side? 

The problem is that you can't avoid writing the user level filters
even if we add this behavior now.

Any tool which wants to work on every single Linux system out there
right now has to accomodate the case where NLM_F_MATCH isn't done by
the kernel.  It will take several years before this would be widely
deployed even if it went in right now.

This means applications are not simplified at all, in fact they become
more complex, since they have to accomodate not just one but two
possible cases.

Specifying this behavior in RFC 3549 is pretty pointless, given the
existing situation.

So the value proposition of adding this change doesn't add up to me.

I'm therefore not inclined to apply a patch like this, sorry.  And even
if I was, I'd ask that ipv4 get it first or at the same time.
