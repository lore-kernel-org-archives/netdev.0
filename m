From: David Miller <davem@davemloft.net>
Subject: Re: [patch -next] amd-xgbe: fix ->rss_hash_type
Date: Wed, 12 Nov 2014 15:04:59 -0500 (EST)
Message-ID: <20141112.150459.233340605780805877.davem@davemloft.net>
References: <20141112083135.GA12795@mwanda>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: thomas.lendacky@amd.com, netdev@vger.kernel.org,
	kernel-janitors@vger.kernel.org
To: dan.carpenter@oracle.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:46072 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753228AbaKLUFB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Nov 2014 15:05:01 -0500
In-Reply-To: <20141112083135.GA12795@mwanda>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dan Carpenter <dan.carpenter@oracle.com>
Date: Wed, 12 Nov 2014 11:31:35 +0300

> There was a missing break statement so we set everything to
> PKT_HASH_TYPE_L3 even when we intended to use PKT_HASH_TYPE_L4.
> 
> Fixes: 5b9dfe299e55 ('amd-xgbe: Provide support for receive side scaling')
> Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>
> ---
> This driver has a lot of Sparse endian warnings.
> http://lwn.net/Articles/205624/
> 
> diff --git a/drivers/net/ethernet/amd/xgbe/xgbe-dev.c b/drivers/net/ethernet/amd/xgbe/xgbe-dev.c
> index 7daa2cd..55ba1dc 100644
> --- a/drivers/net/ethernet/amd/xgbe/xgbe-dev.c
> +++ b/drivers/net/ethernet/amd/xgbe/xgbe-dev.c
> @@ -1601,6 +1601,7 @@ static int xgbe_dev_read(struct xgbe_channel *channel)
>  		case RX_DESC3_L34T_IPV6_UDP:
>  			packet->rss_hash_type = PKT_HASH_TYPE_L4;
>  
> +			break;

Please don't add this spurious empty line before the break;, thanks.
