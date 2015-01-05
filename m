From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH/RFC rocker-net-next 1/6] net: flow: Cancel innermost
 nested attribute first
Date: Mon, 5 Jan 2015 22:01:13 +0000
Message-ID: <20150105220113.GD31637@casper.infradead.org>
References: <1420440610-20621-1-git-send-email-simon.horman@netronome.com>
 <1420440610-20621-2-git-send-email-simon.horman@netronome.com>
 <20150105.161725.1765207203472571760.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: simon.horman@netronome.com, john.fastabend@gmail.com,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:49493 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753179AbbAEWBO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Jan 2015 17:01:14 -0500
Content-Disposition: inline
In-Reply-To: <20150105.161725.1765207203472571760.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01/05/15 at 04:17pm, David Miller wrote:
> From: Simon Horman <simon.horman@netronome.com>
> Date: Mon,  5 Jan 2015 15:50:05 +0900
> 
> > Cancel innermost nested attribute first on error when putting flow actions.
> > 
> > Signed-off-by: Simon Horman <simon.horman@netronome.com>
> > 
> > ---
> > 
> > Its unclear to me if this makes any difference.
> > But it seems more logical to me.
> 
> Hmmm.  Be careful here.  nla_nest_cancel() is just rolling back
> the length of the SKB to right before the netlink attribute being
> given as the cancellation point.
> 
> So you really have to cancel attributes in exactly the reverse order
> in which they were added.  Otherwise we'll make a trim call with a
> negative adjustment that actually expands the SKB past an already
> cancelled attribute.

As I told John in the other the other thread: It is often clearer
and less error prone to only ever cancel the outer most nesting
level if we are undoing all of them anyway. Dave is absolutely right,
a wrong order will lead to bugs which are hard to track down.
Thinking about this I'll send a patch to WARN() in nlmsg_trim() on
mark < skb->data.
