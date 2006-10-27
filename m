From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/8] netpoll: skb private pool management
Date: Thu, 26 Oct 2006 18:08:12 -0700 (PDT)
Message-ID: <20061026.180812.34605098.davem@davemloft.net>
References: <20061026225645.482978803@osdl.org>
	<20061026.171247.133285493.davem@davemloft.net>
	<20061026180402.32c1c511@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:10694
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1423739AbWJ0BIK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 26 Oct 2006 21:08:10 -0400
To: shemminger@osdl.org
In-Reply-To: <20061026180402.32c1c511@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Stephen Hemminger <shemminger@osdl.org>
Date: Thu, 26 Oct 2006 18:04:02 -0700

> On Thu, 26 Oct 2006 17:12:47 -0700 (PDT)
> David Miller <davem@davemloft.net> wrote:
> 
> > From: Stephen Hemminger <shemminger@osdl.org>
> > Date: Thu, 26 Oct 2006 15:46:49 -0700
> > 
> > > @@ -188,19 +186,14 @@ void netpoll_poll(struct netpoll *np)
> > >  static void refill_skbs(void)
> > >  {
> > >  	struct sk_buff *skb;
> > > -	unsigned long flags;
> > >  
> > > -	spin_lock_irqsave(&skb_list_lock, flags);
> > > -	while (nr_skbs < MAX_SKBS) {
> > > +	while (skb_queue_len(&skb_pool) < MAX_SKBS) {
> > 
> > Previously, the lock actually protected nr_skbs from going over
> > MAX_SKBS properly, but the new code does not.  skb_queue_len()
> > is lockless.
> > 
> > Stephen, I really appreciate your efforts to clean up netpoll,
> > but on every iteration I am finding simple errors on the first
> > patch every time.
> 
> racing over by one is not a big issue.

It's potentially racing by more than that, depending upon whether any
cpus take interrupts and are stalled for significiant time after
making the decision to add.  The upper bound is something like
(2 * NCPUS) - 1.

It's a bug Stephen.
