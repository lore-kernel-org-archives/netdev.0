From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH/RFC rocker-net-next 1/6] net: flow: Cancel innermost
 nested attribute first
Date: Mon, 05 Jan 2015 16:17:25 -0500 (EST)
Message-ID: <20150105.161725.1765207203472571760.davem@davemloft.net>
References: <1420440610-20621-1-git-send-email-simon.horman@netronome.com>
	<1420440610-20621-2-git-send-email-simon.horman@netronome.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: john.fastabend@gmail.com, netdev@vger.kernel.org
To: simon.horman@netronome.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:60542 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753140AbbAEVR3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Jan 2015 16:17:29 -0500
In-Reply-To: <1420440610-20621-2-git-send-email-simon.horman@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Simon Horman <simon.horman@netronome.com>
Date: Mon,  5 Jan 2015 15:50:05 +0900

> Cancel innermost nested attribute first on error when putting flow actions.
> 
> Signed-off-by: Simon Horman <simon.horman@netronome.com>
> 
> ---
> 
> Its unclear to me if this makes any difference.
> But it seems more logical to me.

Hmmm.  Be careful here.  nla_nest_cancel() is just rolling back
the length of the SKB to right before the netlink attribute being
given as the cancellation point.

So you really have to cancel attributes in exactly the reverse order
in which they were added.  Otherwise we'll make a trim call with a
negative adjustment that actually expands the SKB past an already
cancelled attribute.
