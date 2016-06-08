From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH -next] cbq: remove only caller of qdisc->drop()
Date: Tue, 07 Jun 2016 17:11:30 -0700 (PDT)
Message-ID: <20160607.171130.496741132362708928.davem@davemloft.net>
References: <1465248027-21652-1-git-send-email-fw@strlen.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: fw@strlen.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:59257 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753638AbcFHALb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Jun 2016 20:11:31 -0400
In-Reply-To: <1465248027-21652-1-git-send-email-fw@strlen.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Westphal <fw@strlen.de>
Date: Mon,  6 Jun 2016 23:20:27 +0200

> since initial revision of cbq in 2004 iproute2 never implemented
> support for TCA_CBQ_OVL_STRATEGY, which is what needs to be set to
> activate the class->drop() call (TC_CBQ_OVL_DROP strategy must be
> set by userspace).
> 
> So lets remove this.  We can even do this in a backwards compatible
> way by switching ovl_drop to perform a dequeue+drop on the leaf.
> 
> A followup commit can then remove all .drop qdisc methods since this
> was the only caller.
> 
> Signed-off-by: Florian Westphal <fw@strlen.de>

I don't see anything, anywhere, using TCA_CBQ_OVL_STRATEGY nor the
various strategy type values.

iproute2 seems to notice the attribute in dumps, but doesn't do
anything with it other than verify that it's size meets some minimum.

It seems really safe to kill this thing off, flag an error if someone
tries to set the attribute, and therefore kill off all of the non-default
cbq_ovl_*() functions.

>   I think it would be safe to just ignore TCA_CBQ_POLICE and change the
>   qdiscs to drop right away.
> 
>   Does anyone have a reason to leave this in the tree?  Thanks!

The TCA_CBQ_POLICE situation looks similar to the TCA_CBQ_OVL_STRATEGY
one to me.

Thanks.
