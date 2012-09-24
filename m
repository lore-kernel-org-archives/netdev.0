From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCHv2 net-next 3/3] vxlan: virtual extensible lan
Date: Mon, 24 Sep 2012 22:09:50 +0200
Message-ID: <1348517390.26828.1601.camel@edumazet-glaptop>
References: <20120924184304.727711327@vyatta.com>
	 <20120924185050.162920909@vyatta.com>
	 <1348515547.26828.1538.camel@edumazet-glaptop>
	 <20120924124657.4541c186@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	Chris Wright <chrisw@redhat.com>, netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f46.google.com ([209.85.214.46]:38332 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750770Ab2IXUJz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Sep 2012 16:09:55 -0400
Received: by bkcjk13 with SMTP id jk13so1161266bkc.19
        for <netdev@vger.kernel.org>; Mon, 24 Sep 2012 13:09:54 -0700 (PDT)
In-Reply-To: <20120924124657.4541c186@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2012-09-24 at 12:46 -0700, Stephen Hemminger wrote:

> +/* Initialize the device structure. */
> +static void vxlan_setup(struct net_device *dev)
> +{
> +	struct vxlan_dev *vxlan = netdev_priv(dev);
> +	unsigned h;
> +
> +	eth_hw_addr_random(dev);
> +	ether_setup(dev);
> +
> +	dev->netdev_ops = &vxlan_netdev_ops;
> +	dev->destructor = vxlan_free;
> +	SET_NETDEV_DEVTYPE(dev, &vxlan_type);
> +
> +	dev->tx_queue_len = 0;
> +	dev->features	|= NETIF_F_LLTX;
> +	dev->features	|= NETIF_F_NETNS_LOCAL;
> +	dev->priv_flags	&= ~IFF_XMIT_DST_RELEASE;

I am not sure why you remove IFF_XMIT_DST_RELEASE here
