From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net v2] ip6_tunnel: fix error code when tunnel exists
Date: Mon, 16 Mar 2015 16:34:13 -0400 (EDT)
Message-ID: <20150316.163413.1468551206666732117.davem@davemloft.net>
References: <20150313.123231.1641333637059823788.davem@davemloft.net>
	<1426517765-4649-1-git-send-email-nicolas.dichtel@6wind.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, me@pierre-cheynier.net,
	eric.dumazet@gmail.com, steffen.klassert@secunet.com
To: nicolas.dichtel@6wind.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:37829 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751385AbbCPUeR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Mar 2015 16:34:17 -0400
In-Reply-To: <1426517765-4649-1-git-send-email-nicolas.dichtel@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Date: Mon, 16 Mar 2015 15:56:05 +0100

> @@ -1445,7 +1445,7 @@ ip6_tnl_ioctl(struct net_device *dev, struct ifreq *ifr, int cmd)
>  		ip6_tnl_parm_from_user(&p1, &p);
>  		t = ip6_tnl_locate(net, &p1, cmd == SIOCADDTUNNEL);
>  		if (cmd == SIOCCHGTUNNEL) {
> -			if (t != NULL) {
> +			if (!IS_ERR(t)) {
>  				if (t->dev != dev) {
>  					err = -EEXIST;
>  					break;

Please convert that last assignment to "err = PTR_ERR(t);", thanks.
