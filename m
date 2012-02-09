From: David Miller <davem@davemloft.net>
Subject: Re: BUG: unable to handle kernel NULL pointer dereference at
 000000000000002c
Date: Wed, 08 Feb 2012 20:26:51 -0500 (EST)
Message-ID: <20120208.202651.97221367956126026.davem@davemloft.net>
References: <4F2B8348.3090305@profihost.ag>
	<1328253972.2480.42.camel@edumazet-laptop>
	<4F2B963F.4020504@profihost.ag>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, gregkh@linuxfoundation.org,
	jwboyer@gmail.com, hch@infradead.org, netdev@vger.kernel.org,
	david@fromorbit.com, stable@vger.kernel.org
To: s.priebe@profihost.ag
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:49961 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750813Ab2BIB2V (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Feb 2012 20:28:21 -0500
In-Reply-To: <4F2B963F.4020504@profihost.ag>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stefan Priebe - Profihost AG <s.priebe@profihost.ag>
Date: Fri, 03 Feb 2012 09:09:35 +0100

> Hi,
> 
> attached you find the patch files applying cleanly to 3.0.X.
> 
>>> I've made my own backport of the patch and removed at least 1-2
>>> dependencies. Anybody interested?
>>>
>> 
>> If you did the work, post it for review.
> 
> Thanks!

I think you backported way too much, the ->lookup_neigh() dst ops
abstraction is unnecessary, all of the neighbour hash function
changes are also completely unnecessary.

All you needed to backport is that bit that abstracts dst->neighbour()
behind helper routines.

The point of this exercise is not to keep backporting changes until
the subsequent patch applies cleanly, it's to backport the minimal
amount necessary to get the effect of the patch you're ultimately
interested in adding.

I'll work on coming up with something much more sensible tonight.
