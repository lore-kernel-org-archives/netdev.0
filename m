From: Darek Marcinkiewicz <reksio@newterm.pl>
Subject: Re: [PATCH v8 1/1] Driver for Beckhoff CX5020 EtherCAT master module.
Date: Tue, 6 May 2014 22:18:15 +0200
Message-ID: <20140506201815.GL1156@newterm.pl>
References: <20140505191045.GK1156@newterm.pl>
 <20140506145606.GH6455@distanz.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, romieu@fr.zoreil.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Tobias Klauser <tklauser@distanz.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.newterm.pl ([79.187.237.18]:51560 "EHLO apollo.newterm.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754779AbaEFUSR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 6 May 2014 16:18:17 -0400
Content-Disposition: inline
In-Reply-To: <20140506145606.GH6455@distanz.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, May 06, 2014 at 04:56:06PM +0200, Tobias Klauser wrote:
> > +		if (skb) {
> > +			memcpy(skb_put(skb, pkt_size), data, pkt_size);
> > +			skb->protocol = eth_type_trans(skb, priv->net_dev);
> > +			dev_dbg(dev, "Protocol type: %x\n", skb->protocol);
> > +
> > +			netif_rx(skb);
> > +		} else {
> > +			dev_err_ratelimited(dev,
> > +				"Couldn't allocate a skb_buff for a packet of size %u\n",
> > +				pkt_size);
> > +		}
> > +
> > +		priv->stat_rx_bytes += pkt_size;
> 
> This should only be incremented if the packet was actually passed to
> netif_rx(), no?
Yes, I guees it should.
> 
> > +
> > +static struct rtnl_link_stats64 *
> > +ec_bhf_get_stats(struct net_device *net_dev,
> > +		 struct rtnl_link_stats64 *stats)
> > +{
> > +	struct ec_bhf_priv *priv = netdev_priv(net_dev);
> > +
> > +	memset(stats, 0, sizeof(*stats));
> 
> No need to memset() here, this is already done in dev_get_stats()
> 
Ok, thanks. Will send updated patch.

-- 
DM
