From: Patrick McHardy <kaber@trash.net>
Subject: Re: [NET_SCHED 11/11]: qdisc: avoid dequeue while throttled
Date: Fri, 23 Mar 2007 15:57:08 +0100
Message-ID: <4603EAC4.7000509@trash.net>
References: <20070323133513.10264.16515.sendpatchset@localhost.localdomain> <20070323133528.10264.68156.sendpatchset@localhost.localdomain> <4603E6AE.6000606@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:62975 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S2992438AbXCWO5h (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 Mar 2007 10:57:37 -0400
In-Reply-To: <4603E6AE.6000606@trash.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Patrick McHardy wrote:
>>[NET_SCHED]: qdisc: avoid dequeue while throttled
> 
> 
> It just occured to me that this doesn't work properly with qdiscs
> that have multiple classes since they all don't properly maintain
> the TCQ_F_THROTTLED flag. They set it on dequeue when no active
> class is willing to give out packets, but when enqueueing to a
> non-active class (thereby activating it) it is still set even though
> we don't know if that class could be dequeued.
> 
> So this updated patch unsets the TCQ_F_THROTTLED flag whenever we
> activate a class. Additionally it removes the unsetting of
> TCQ_F_THROTTLED on successful dequeue since we're now guaranteed
> that it was not set before.


I found another case that doesn't work properly, so let me retract
this patch until I've properly thought this through.

