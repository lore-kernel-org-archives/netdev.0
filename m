From: Paul Moore <paul.moore@hp.com>
Subject: Re: [RFC PATCH] NET: Clone the sk_buff->iif field properly
Date: Thu, 3 Jan 2008 09:01:37 -0500
Message-ID: <200801030901.38962.paul.moore@hp.com>
References: <20080103095829.GB2000@ff.dom.local> <1199359402.4710.17.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Jarek Poplawski <jarkao2@gmail.com>, netdev@vger.kernel.org
To: hadi@cyberus.ca
Return-path: <netdev-owner@vger.kernel.org>
Received: from g4t0016.houston.hp.com ([15.201.24.19]:18248 "EHLO
	g4t0016.houston.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750823AbYACOB4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Jan 2008 09:01:56 -0500
In-Reply-To: <1199359402.4710.17.camel@localhost>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thursday 03 January 2008 6:23:22 am jamal wrote:
> On Thu, 2008-03-01 at 10:58 +0100, Jarek Poplawski wrote:
> > On 02-01-2008 17:01, Paul Moore wrote:
> > > This patch is needed by some of the labeled networking changes proposed
> > > for 2.6.25, does anyone have any objections?
> >
> > Probably Jamal could be the most interested (added to CC):
>
> Gracias Jarek.

Yes, thank you.  One of these days I need to learn some git commands other 
than clone, update, and push ;)

> Paul, (out of curiosity more than anything) what are the circumstances
> of the cloned skb - are you going to reinject it back at some point?

Well, I'm not planning on reinjecting the cloned skb at present (doesn't mean 
I won't think up some contrived use in the future) but the stack appears to 
do this already in a few cases and it is causing problems when we try to 
perform access control on the cloned skb.  The git-lblnet "horkage" in 
the -mm tree just before the holiday is the most notable example.

> I cant think of any good reason why iif shouldnt be copied - thats how
> its been from the begining (dammit;->). The reason it hasnt mattered so
> far is everything that needs to write the iif never copied (refer to
> Documentation/networking/tc-actions-env-rules.txt). For correctness i
> think it should be copied. So no objections;

Great.

> The better patch would be to just put it in skb_clone and remove it from
> tc_act_clone.

I assume you mean skb_act_clone()?  That sounds like the best idea, I'll fixup 
the patch and resend it today for more review.

Thanks guys.

-- 
paul moore
linux security @ hp
