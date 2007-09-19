From: David Miller <davem@davemloft.net>
Subject: Re: SFQ qdisc crashes with limit of 2 packets
Date: Wed, 19 Sep 2007 10:43:00 -0700 (PDT)
Message-ID: <20070919.104300.92582764.davem@davemloft.net>
References: <46F023D0.7030307@trash.net>
	<20070919094803.GA17740@ms2.inr.ac.ru>
	<46F11F46.8060108@trash.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kuznet@ms2.inr.ac.ru, cebbert@redhat.com, netdev@vger.kernel.org
To: kaber@trash.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:46270
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1760159AbXISRnA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Sep 2007 13:43:00 -0400
In-Reply-To: <46F11F46.8060108@trash.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Patrick McHardy <kaber@trash.net>
Date: Wed, 19 Sep 2007 15:08:22 +0200

> Alexey Kuznetsov wrote:
> > Hello!
> > 
> >>CCed Alexey just to be safe, but I think the patch should be fine.
> > 
> > 
> > Yes. But what'a about limit == 1? tc prohibits this case, but it is still
> > not nice to have the bug in kernel. Plus, code remains creepy, the check
> > 
> > +	if (++sch->q.qlen < q->limit) {
> > 
> > still looks as a scary off-by-one. I would go all the way: replace this
> > with natural:
> > 
> > 	if (++sch->q.qlen <= q->limit) {
> > 
> > and maxed q->limit at SFQ_DEPTH-2. Patch enclosed.
> 
> Thats even better, thanks :)

I'll put this into my tree and wait while Alexey does his tests.

Thanks.

