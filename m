From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: [PATCH 1/5] netpoll: use sk_buff_head for txq
Date: Tue, 24 Oct 2006 07:51:30 -0700
Message-ID: <20061024075130.6e4cf8d2@dads-laptop>
References: <20061020153027.3bed8c86@dxpl.pdx.osdl.net>
	<20061022.204220.78710782.davem@davemloft.net>
	<20061023120253.5dd146d2@dxpl.pdx.osdl.net>
	<20061023.230350.05157566.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:8116 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S932295AbWJXOvh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Oct 2006 10:51:37 -0400
To: David Miller <davem@davemloft.net>
In-Reply-To: <20061023.230350.05157566.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 23 Oct 2006 23:03:50 -0700 (PDT)
David Miller <davem@davemloft.net> wrote:

> From: Stephen Hemminger <shemminger@osdl.org>
> Date: Mon, 23 Oct 2006 12:02:53 -0700
> 
> > +	spin_lock_irqsave(&netpoll_txq.lock, flags);
> > +	for (skb = (struct sk_buff *)netpoll_txq.next;
> > +	     skb != (struct sk_buff *)&netpoll_txq; skb = next) {
> > +		next = skb->next;
> > +		if (skb->dev == dev) {
> > +			skb_unlink(skb, &netpoll_txq);
> > +			kfree_skb(skb);
> > +		}
> >  	}
> > +	spin_unlock_irqrestore(&netpoll_txq.lock, flags);
> 
> IRQ's are disabled, I think we can't call kfree_skb() in such a
> context.

It is save since the skb's only come from this code (no destructors).

> 
> That's why zap_completion_queue() has all of these funny
> skb->destructor checks and such, all of this stuff potentially runs in
> IRQ context.

It should use __kfree_skb in the purge routine (like other places).
