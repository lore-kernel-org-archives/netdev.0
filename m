From: Florian Westphal <fw@strlen.de>
Subject: Re: [PATCH 1/1] net_sched: drr: warn when qdisc is not work
 conserving
Date: Thu, 12 Jun 2014 18:38:03 +0200
Message-ID: <20140612163803.GD1982@breakpoint.cc>
References: <1402511718-24203-1-git-send-email-fw@strlen.de>
 <aa75d9b0-e643-4fbe-b2bd-1c85982752e0@email.android.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Florian Westphal <fw@strlen.de>, netdev@vger.kernel.org
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([80.244.247.6]:55486 "EHLO
	Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753068AbaFLQiF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Jun 2014 12:38:05 -0400
Content-Disposition: inline
In-Reply-To: <aa75d9b0-e643-4fbe-b2bd-1c85982752e0@email.android.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Patrick McHardy <kaber@trash.net> wrote:
> On 11. Juni 2014 20:35:18 MESZ, Florian Westphal <fw@strlen.de> wrote:
> >The DRR scheduler requires that items on the active list are work
> >conserving, i.e. do not hold on to skbs for throttling purposes, etc.
> >Attaching e.g. tbf renders DRR useless because all other classes on the
> >active list are delayed as well.
> >
> >So, warn users that this configuration won't work as expected; we
> >already do this in couple of other qdiscs, see e.g.
> 
> Why don't prevent this during configuration time in the first place?
> It doesn't work, a warning might trigger long after creating the broken
> configuration and will more likely go unnoticed.

That would be nice.

But that would require some annotation of the qdiscs wheter they're
wc or not, right?

With such annotation, qdisc_graft() could refuse such request.

Is that what you have in mind?
