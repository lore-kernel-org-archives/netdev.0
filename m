From: Simon Horman <horms@verge.net.au>
Subject: Re: [net-next PATCH 2/6] enic: Bug fix: try harder to fill Rx ring
 on skb allocation failures
Date: Sun, 20 Dec 2009 17:14:38 +1100
Message-ID: <20091220061438.GA12552@verge.net.au>
References: <20091220011500.GA12578@verge.net.au>
 <C752BE07.1B019%scofeldm@cisco.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Scott Feldman <scofeldm@cisco.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from kirsty.vergenet.net ([202.4.237.240]:34598 "EHLO
	kirsty.vergenet.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750811AbZLTGOj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 20 Dec 2009 01:14:39 -0500
Content-Disposition: inline
In-Reply-To: <C752BE07.1B019%scofeldm@cisco.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Dec 19, 2009 at 05:29:43PM -0800, Scott Feldman wrote:
> On 12/19/09 5:15 PM, "Simon Horman" <horms@verge.net.au> wrote:
> 
> > On Sat, Dec 19, 2009 at 12:39:03PM -0800, Scott Feldman wrote:
> >>>> +  rq_work_done = rq_work_to_do;
> >>> 
> >>> Is it intentional for rq_work_done = rq_work_to_do to become the
> >>> return value?
> >> 
> >> That was intentional.  If the replacement skb allocation fails, we're
> >> returning like we did a full budget's worth of work so we stay scheduled and
> >> hopefully the next polling pass we'll get the allocations.  Before this fix,
> >> there is a corner case which isn't covered: if hw has used all descs and
> >> gens an intr and we get into polling and the replacement alloc fails, then
> >> Rx is hung.  Hw is desc starved and we're not going to get any more intrs:
> >> game over.
> > 
> > Ok, understood. Though doesn't this fix just narrow the scope for that
> > failure? It seems that it could still occur in a pathological case.
> 
> Oh!  The intention was to fix it absolutely.  Please expand on the
> pathological case your thinking about.  We need this 100% solved, but now
> you've got me worried...  ;)

Perhaps I am misunderstanding the problem, but what if the budget in
net_rx_action() is exhausted before a call to enic_poll*() successfully
allocs?

