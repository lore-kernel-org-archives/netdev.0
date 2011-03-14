From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH][v3] dev : fix mtu check when TSO is enabled
Date: Mon, 14 Mar 2011 16:59:29 -0700 (PDT)
Message-ID: <20110314.165929.232913682.davem@davemloft.net>
References: <1300135190-14093-1-git-send-email-daniel.lezcano@free.fr>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, kaber@trash.net, nightnord@gmail.com,
	netdev@vger.kernel.org
To: daniel.lezcano@free.fr
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:46536
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753236Ab1CNX6v (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Mar 2011 19:58:51 -0400
In-Reply-To: <1300135190-14093-1-git-send-email-daniel.lezcano@free.fr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniel Lezcano <daniel.lezcano@free.fr>
Date: Mon, 14 Mar 2011 21:39:50 +0100

> +	len = dev->mtu + dev->hard_header_len + VLAN_HLEN;
> +	if (skb->len < len)
> +		return true;

This is not a correct translation of the original test:

> -		     (skb->len > (dev->mtu + dev->hard_header_len + VLAN_HLEN)))) {

You need to use "<=" in your version, which currently rejects all
full sized frames. :-)

> +
> +	/* if TSO is enabled, we don't care about the length as the packet
> +	 * could be forwarded without being segmented before
> +	 */
> +	if (skb->dev && skb->dev->features & NETIF_F_TSO)
> +		return true;

I am trying to understand why you aren't simply checking also if this
is a segmented frame?  Perhaps skb_is_gso() && device has NETIF_F_TSO
set?

