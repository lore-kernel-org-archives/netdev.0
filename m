From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH net-next 1/5] dsa: add support for Microchip KSZ tail
 tagging
Date: Sat, 6 May 2017 05:38:43 +0200
Message-ID: <20170506033843.GA14749@lunn.ch>
References: <9235D6609DB808459E95D78E17F2E43D40A5BFEC@CHN-SV-EXMX02.mchp-main.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: f.fainelli@gmail.com, vivien.didelot@savoirfairelinux.com,
        netdev@vger.kernel.org, davem@davemloft.net,
        UNGLinuxDriver@microchip.com
To: Woojung.Huh@microchip.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:51864 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750949AbdEFDit (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 5 May 2017 23:38:49 -0400
Content-Disposition: inline
In-Reply-To: <9235D6609DB808459E95D78E17F2E43D40A5BFEC@CHN-SV-EXMX02.mchp-main.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> +static struct sk_buff *ksz_xmit(struct sk_buff *skb, struct net_device *dev)
> +{
> +	struct dsa_slave_priv *p = netdev_priv(dev);
> +	struct sk_buff *nskb;
> +	int padlen;
> +	u8 *tag;
> +
> +	padlen = 0;
> +	if (skb->len < 60)
> +		padlen = 60 - skb->len;
> +
> +	nskb = alloc_skb(NET_IP_ALIGN + skb->len + padlen + 2, GFP_ATOMIC);
> +	if (!nskb) {
> +		kfree_skb(skb);
> +		return NULL;
> +	}
> +	skb_reserve(nskb, NET_IP_ALIGN);
> +
> +	skb_reset_mac_header(nskb);
> +	skb_set_network_header(nskb, skb_network_header(skb) - skb->head);
> +	skb_set_transport_header(nskb, skb_transport_header(skb) - skb->head);
> +	skb_copy_and_csum_dev(skb, skb_put(nskb, skb->len));
> +	kfree_skb(skb);

Hi Woojung

Is there really no way to add data to the end of an existing skb?
skb_put(), once you have checked there is space? Only do the copy if
there is no space.

	   Andrew
