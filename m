From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] vlan_dev: VLAN 0 should be treated as "no vlan tag"
 (802.1p packet)
Date: Wed, 30 Jun 2010 13:16:16 -0700 (PDT)
Message-ID: <20100630.131616.233403329.davem@davemloft.net>
References: <311b59aee7d648c6124a84b5ca06ac60@dondevamos.com>
	<1276679284.2632.22.camel@edumazet-laptop>
	<c38a6e1add643eb78bd0d28ee3984cf4@dondevamos.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kaber@trash.net, bhutchings@solarflare.com,
	eric.dumazet@gmail.com
To: pedro.netdev@dondevamos.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:46161
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754743Ab0F3UQD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Jun 2010 16:16:03 -0400
In-Reply-To: <c38a6e1add643eb78bd0d28ee3984cf4@dondevamos.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Pedro Garcia <pedro.netdev@dondevamos.com>
Date: Mon, 28 Jun 2010 01:21:19 +0200

> Last version of the patch. Now I think it is OK, of course pending 
> Eric's signed-off-by for the accel HW part.

Eric, please review.

> 
> If this is too long for a changelog, tell me and I will try to sum it
> up:

To me, not commit message is too long, the more the better. :)

> +       if ((event == NETDEV_UP) &&
> +           (dev->features & NETIF_F_HW_VLAN_FILTER) &&
> +           (dev->netdev_ops->ndo_vlan_rx_add_vid)) {

There is no reason to surround this final NULL pointer check with
parenthesis, it just makes reading it confusing.
> +       if (vlan_dev)
> +               skb->dev = vlan_dev;
> +       else
> +               if (vlan_id)
> +                       goto drop;

Please format this as:

	if (a)
		b;
	else if (c)
		d;


> +       if (vlan_dev)
> +               skb->dev = vlan_dev;
> +       else
> +               if (vlan_id)
> +                       goto drop;

Same here.
