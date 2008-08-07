From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: qdisc_enqueue, NET_XMIT_SUCCESS and kfree_skb
Date: Thu, 7 Aug 2008 10:09:10 +0000
Message-ID: <20080807100910.GA12391@ff.dom.local>
References: <20080806224248.18266k9ahc5nkk8w@hayate.ip6> <20080806215258.GA3306@ami.dom.local> <20080806.202636.246995904.davem@davemloft.net> <20080806.220911.91192536.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jussi.kivilinna@mbnet.fi, kaber@trash.net, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ik-out-1112.google.com ([66.249.90.182]:47184 "EHLO
	ik-out-1112.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756875AbYHGMmP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Aug 2008 08:42:15 -0400
Received: by ik-out-1112.google.com with SMTP id c28so423736ika.5
        for <netdev@vger.kernel.org>; Thu, 07 Aug 2008 05:42:13 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20080806.220911.91192536.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Aug 06, 2008 at 10:09:11PM -0700, David Miller wrote:
> From: David Miller <davem@davemloft.net>
> Date: Wed, 06 Aug 2008 20:26:36 -0700 (PDT)
> 
> > 
> > I still haven't seen anyone suggest creating a __NET_XMIT_KFREE_SKB to
> > fix this most rediculious problem.
> > 
> > I'm still waiting...
> 
> Here is what it might look like.  I haven't tried to boot this,
> but the only non-trivial case was SFQ's congestion drop code.

After some checking it looks mostly OK to me, but one thing: in
sch_gred gred_drop() calls qdisc_drop(), so now it needs kfree_skb().
BTW, maybe it would be nicer to add __qdisc_drop() for these new
things?

There is also some doubt about differences between ->enqueue() and
->requeue() wrt. kfree_skb() and returning codes: maybe it would be
better (for uniformity) to add similar changes to requeues (and
dev_requeue_skb()) as well?

I don't know if it's worth to mention, but now, if somebody really
uses this sch_blackhole under some upper qdiscs the stats will change.

Jarek P.
