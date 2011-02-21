From: Andy Gospodarek <andy@greyhouse.net>
Subject: Re: [PATCH] bonding: bond_select_queue off by one
Date: Mon, 21 Feb 2011 13:06:46 -0500
Message-ID: <20110221180646.GD11864@gospo.rdu.redhat.com>
References: <20110218020713.GA9696@linuxace.com> <22094.1298004108@death> <20110218224958.GC11864@gospo.rdu.redhat.com> <1298070372.2211.59.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andy Gospodarek <andy@greyhouse.net>,
	Jay Vosburgh <fubar@us.ibm.com>,
	Phil Oester <kernel@linuxace.com>, netdev@vger.kernel.org
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:30304 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752781Ab1BUSNw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 21 Feb 2011 13:13:52 -0500
Content-Disposition: inline
In-Reply-To: <1298070372.2211.59.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Feb 18, 2011 at 11:06:12PM +0000, Ben Hutchings wrote:
> On Fri, 2011-02-18 at 17:49 -0500, Andy Gospodarek wrote:
> > --- a/include/linux/skbuff.h
> > +++ b/include/linux/skbuff.h
> > @@ -2194,6 +2194,21 @@ static inline bool skb_rx_queue_recorded(const struct sk_buff *skb)
> >         return skb->queue_mapping != 0;
> >  }
> >  
> > +static inline void skb_record_tx_queue(struct sk_buff *skb, u16 tx_queue)
> > +{
> > +       skb->queue_mapping = tx_queue + 1;
> > +}
> > +
> > +static inline u16 skb_get_tx_queue(const struct sk_buff *skb)
> > +{
> > +       return skb->queue_mapping - 1;
> > +}
> > +
> > +static inline bool skb_tx_queue_recorded(const struct sk_buff *skb)
> > +{
> > +       return skb->queue_mapping != 0;
> > +}
> > +
> [...]
> 
> This is nonsense.  After the TX queue has been selected, it's recorded
> in queue_mapping *without* the offset (skb_set_queue_mapping()).
> 

I see that now.  Yay for symmetry! :)

I'm actually looking over this now and will post a tested patch to
address the original reporter's problem.


