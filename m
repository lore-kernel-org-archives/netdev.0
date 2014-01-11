From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH net-next] net: replace macros net_random and net_srandom with direct calls to prandom
Date: Sat, 11 Jan 2014 19:00:25 +0100
Message-ID: <20140111180025.GB6586@order.stressinduktion.org>
References: <1389442559-13097-1-git-send-email-aruna.hewapathirane@gmail.com> <1389462757.2537.61.camel@joe-AO722>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: Aruna-Hewapathirane <aruna.hewapathirane@gmail.com>,
	netdev@vger.kernel.org
To: Joe Perches <joe@perches.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:56788 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751274AbaAKSA1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 11 Jan 2014 13:00:27 -0500
Content-Disposition: inline
In-Reply-To: <1389462757.2537.61.camel@joe-AO722>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Jan 11, 2014 at 09:52:37AM -0800, Joe Perches wrote:
> On Sat, 2014-01-11 at 07:15 -0500, Aruna-Hewapathirane wrote:
> > This patch removes the net_random and net_srandom macros and replaces
> > them with direct calls to the prandom ones. As new commits only seem to
> > use prandom_u32 there is no use to keep them around.
> > This change makes it easier to grep for users of prandom_u32.
> 
> Seems sensible.
> 
> Also, there may be some value in a future patch
> to use reciprocal_divide in a few places
> 
> > diff --git a/net/802/garp.c b/net/802/garp.c
> > @@ -397,7 +397,7 @@ static void garp_join_timer_arm(struct garp_applicant *app)
> >  {
> >  	unsigned long delay;
> >  
> > -	delay = (u64)msecs_to_jiffies(garp_join_time) * net_random() >> 32;
> > +	delay = (u64)msecs_to_jiffies(garp_join_time) * prandom_u32() >> 32;
> 
> reciprocal_divide()

Does reciprocal_divide() make sense without reciprocal_value() from a
stylish point of view?

I wouldn't do that just because it expands into the same code.

Greetings,

  Hannes
