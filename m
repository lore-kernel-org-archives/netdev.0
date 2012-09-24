From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCHv2 net-next 3/3] vxlan: virtual extensible lan
Date: Mon, 24 Sep 2012 13:26:37 -0700
Message-ID: <20120924132637.17d89210@nehalam.linuxnetplumber.net>
References: <20120924184304.727711327@vyatta.com>
	<20120924185050.162920909@vyatta.com>
	<1348515547.26828.1538.camel@edumazet-glaptop>
	<20120924124657.4541c186@nehalam.linuxnetplumber.net>
	<1348517390.26828.1601.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	Chris Wright <chrisw@redhat.com>, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:59141 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757974Ab2IXU1I (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 24 Sep 2012 16:27:08 -0400
In-Reply-To: <1348517390.26828.1601.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 24 Sep 2012 22:09:50 +0200
Eric Dumazet <eric.dumazet@gmail.com> wrote:

> On Mon, 2012-09-24 at 12:46 -0700, Stephen Hemminger wrote:
> 
> > +/* Initialize the device structure. */
> > +static void vxlan_setup(struct net_device *dev)
> > +{
> > +	struct vxlan_dev *vxlan = netdev_priv(dev);
> > +	unsigned h;
> > +
> > +	eth_hw_addr_random(dev);
> > +	ether_setup(dev);
> > +
> > +	dev->netdev_ops = &vxlan_netdev_ops;
> > +	dev->destructor = vxlan_free;
> > +	SET_NETDEV_DEVTYPE(dev, &vxlan_type);
> > +
> > +	dev->tx_queue_len = 0;
> > +	dev->features	|= NETIF_F_LLTX;
> > +	dev->features	|= NETIF_F_NETNS_LOCAL;
> > +	dev->priv_flags	&= ~IFF_XMIT_DST_RELEASE;
> 
> I am not sure why you remove IFF_XMIT_DST_RELEASE here

Copied from GRE. What is impact either way? 
