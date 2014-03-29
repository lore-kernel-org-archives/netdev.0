From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: fec: make sure to init MAC address
Date: Sat, 29 Mar 2014 18:54:29 -0400 (EDT)
Message-ID: <20140329.185429.613403614921271282.davem@davemloft.net>
References: <1396048764-3301-1-git-send-email-dev@lynxeye.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kernel@pengutronix.de,
	l.stach@pengutronix.de
To: dev@lynxeye.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:51352 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751878AbaC2Wya (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 29 Mar 2014 18:54:30 -0400
In-Reply-To: <1396048764-3301-1-git-send-email-dev@lynxeye.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Lucas Stach <dev@lynxeye.de>
Date: Sat, 29 Mar 2014 00:19:24 +0100

> @@ -1898,10 +1898,11 @@ fec_set_mac_address(struct net_device *ndev, void *p)
>  	struct fec_enet_private *fep = netdev_priv(ndev);
>  	struct sockaddr *addr = p;
>  
> -	if (!is_valid_ether_addr(addr->sa_data))
> -		return -EADDRNOTAVAIL;
> -
> -	memcpy(ndev->dev_addr, addr->sa_data, ndev->addr_len);
> +	if (p) {
> +		if (!is_valid_ether_addr(addr->sa_data))
> +			return -EADDRNOTAVAIL;
> +		memcpy(ndev->dev_addr, addr->sa_data, ndev->addr_len);
> +	}

This test looks awkward, if we're going to dereference and
use 'addr', then test 'addr' instead of 'p'.

Thanks.
