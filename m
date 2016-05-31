From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/2] macvlan: Avoid unnecessary multicast cloning
Date: Tue, 31 May 2016 14:07:13 -0700 (PDT)
Message-ID: <20160531.140713.2187659962450926738.davem@davemloft.net>
References: <20160526234433.GU8402@wantstofly.org>
	<20160530081752.GA4956@gondor.apana.org.au>
	<20160530082828.GB5106@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: buytenh@wantstofly.org, kaber@trash.net, netdev@vger.kernel.org,
	jpirko@redhat.com
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:37498 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750813AbcEaVHP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 31 May 2016 17:07:15 -0400
In-Reply-To: <20160530082828.GB5106@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Mon, 30 May 2016 16:28:28 +0800

> @@ -725,6 +730,8 @@ static void macvlan_set_mac_lists(struct net_device *dev)
>  {
>  	struct macvlan_dev *vlan = netdev_priv(dev);
>  
> +	dev_uc_sync(vlan->lowerdev, dev);
> +	dev_mc_sync(vlan->lowerdev, dev);
>  	if (dev->flags & (IFF_PROMISC | IFF_ALLMULTI)) {
>  		bitmap_fill(vlan->mc_filter, MACVLAN_MC_FILTER_SZ);
>  	} else {

I think you need to set the vlan->port->mc_filter to all 1's in the
PROMISC/ALLMUTI branch here.

Otherwise packets won't properly pass your new hash test.
