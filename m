From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [PATCH] jme: Fix DMA unmap warning
Date: Sun, 11 May 2014 09:04:29 -0400
Message-ID: <20140511130429.GB13495@hmsreliant.think-freely.org>
References: <1399315907-27148-1-git-send-email-nhorman@tuxdriver.com>
 <1399812569.11946.131.camel@deadeye.wl.decadent.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Guo-Fu Tseng <cooldavid@cooldavid.org>,
	"David S. Miller" <davem@davemloft.net>
To: Ben Hutchings <ben@decadent.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:56813 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751045AbaEKNEe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 11 May 2014 09:04:34 -0400
Content-Disposition: inline
In-Reply-To: <1399812569.11946.131.camel@deadeye.wl.decadent.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, May 11, 2014 at 01:49:29PM +0100, Ben Hutchings wrote:
> On Mon, 2014-05-05 at 14:51 -0400, Neil Horman wrote:
> [...] 
> > -static void
> > +static void jme_drop_tx_map(struct jme_adapter *jme, int startidx, int endidx)
> > +{
> > +	struct jme_ring *txring = &(jme->txring[0]);
> > +	struct jme_buffer_info *txbi = txring->bufinf, *ctxbi;
> > +	int mask = jme->tx_ring_mask;
> > +	int j;
> > +
> > +	for (j = startidx ; j < endidx ; ++j) {
> > +		ctxbi = txbi + ((startidx + j + 2) & (mask));
> 
> So you're starting at startidx * 2 + 2, that can't be right.
> 
Shoot, I think j needs to be initalized to 0.

> [...]
> > @@ -2228,7 +2268,8 @@ jme_start_xmit(struct sk_buff *skb, struct net_device *netdev)
> >  		return NETDEV_TX_BUSY;
> >  	}
> >  
> > -	jme_fill_tx_desc(jme, skb, idx);
> > +	if (jme_fill_tx_desc(jme, skb, idx))
> > +		return NETDEV_TX_BUSY;
> 
> NETDEV_TX_OK
> 
Yup, I'll send a subsequent patch to fix it.  Thanks
Neil

> Ben.
> 
> >  	jwrite32(jme, JME_TXCS, jme->reg_txcs |
> >  				TXCS_SELECT_QUEUE0 |
> 
> -- 
> Ben Hutchings
> Sturgeon's Law: Ninety percent of everything is crap.
