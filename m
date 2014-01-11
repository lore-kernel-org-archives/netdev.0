From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH net-next] net: replace macros net_random and net_srandom
 with direct calls to prandom
Date: Sat, 11 Jan 2014 10:43:09 -0800
Message-ID: <1389465789.2537.66.camel@joe-AO722>
References: <1389442559-13097-1-git-send-email-aruna.hewapathirane@gmail.com>
	 <1389462757.2537.61.camel@joe-AO722>
	 <20140111180025.GB6586@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Aruna-Hewapathirane <aruna.hewapathirane@gmail.com>,
	netdev@vger.kernel.org
To: Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtprelay0041.hostedemail.com ([216.40.44.41]:52496 "EHLO
	smtprelay.hostedemail.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751274AbaAKSnN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 11 Jan 2014 13:43:13 -0500
In-Reply-To: <20140111180025.GB6586@order.stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 2014-01-11 at 19:00 +0100, Hannes Frederic Sowa wrote:
> On Sat, Jan 11, 2014 at 09:52:37AM -0800, Joe Perches wrote:
> > On Sat, 2014-01-11 at 07:15 -0500, Aruna-Hewapathirane wrote:
> > > This patch removes the net_random and net_srandom macros and replaces
> > > them with direct calls to the prandom ones. As new commits only seem to
> > > use prandom_u32 there is no use to keep them around.
> > > This change makes it easier to grep for users of prandom_u32.
> > 
> > Seems sensible.
> > 
> > Also, there may be some value in a future patch
> > to use reciprocal_divide in a few places
> > 
> > > diff --git a/net/802/garp.c b/net/802/garp.c
> > > @@ -397,7 +397,7 @@ static void garp_join_timer_arm(struct garp_applicant *app)
> > >  {
> > >  	unsigned long delay;
> > >  
> > > -	delay = (u64)msecs_to_jiffies(garp_join_time) * net_random() >> 32;
> > > +	delay = (u64)msecs_to_jiffies(garp_join_time) * prandom_u32() >> 32;
> > 
> > reciprocal_divide()
> 
> Does reciprocal_divide() make sense without reciprocal_value() from a
> stylish point of view?

Hi again.

Dunno.

I think there's some value in the name triggering
reader recognition of what the code is doing.

> I wouldn't do that just because it expands into the same code.

There are a few places where reciprocal_device is
used today without using reciprocal_value()
