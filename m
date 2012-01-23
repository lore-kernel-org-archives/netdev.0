From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [patch v1, kernel version 3.2.1] Source mode for macvlan
 interaface
Date: Mon, 23 Jan 2012 16:25:14 +0100
Message-ID: <1327332314.2525.25.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
References: <22013455.801327321838477.JavaMail.root@5-MeO-DMT.ynet.sk>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Patrick McHardy <kaber@trash.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Stefan Gula <steweg@ynet.sk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f174.google.com ([74.125.82.174]:41514 "EHLO
	mail-we0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751202Ab2AWPZS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Jan 2012 10:25:18 -0500
In-Reply-To: <22013455.801327321838477.JavaMail.root@5-MeO-DMT.ynet.sk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le lundi 23 janvier 2012 =C3=A0 13:30 +0100, Stefan Gula a =C3=A9crit :

> +static void macvlan_forward_sources_one(struct sk_buff *skb,
> +					struct macvlan_dev *vlan)
> +{
> +	struct sk_buff *nskb;
> +	struct net_device *dev;
> +	int len;
> +	int ret;
> +
> +	dev =3D vlan->dev;
> +	if (unlikely(!(dev->flags & IFF_UP)))
> +		return;
> +
> +	nskb =3D skb_clone(skb, GFP_ATOMIC);
> +	if (!nskb)
> +		return;
> +
> +	len =3D nskb->len + ETH_HLEN;
> +	nskb =3D skb_share_check(nskb, GFP_ATOMIC);
> +	if (!nskb)
> +		return;

I am trying to understand how/why skb_share_check() is needed/useful
after skb_clone() ...
