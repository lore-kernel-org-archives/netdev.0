From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Re: [PATCH] NET: Validate device addr prior to interface-up
Date: Wed, 24 Oct 2007 06:46:40 -0700
Message-ID: <20071024064640.3f6dcc7d@shemminger-laptop>
References: <20071024023313.GA19263@havoc.gtf.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:60698 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757635AbXJXNq5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Oct 2007 09:46:57 -0400
In-Reply-To: <20071024023313.GA19263@havoc.gtf.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


> diff --git a/net/ethernet/eth.c b/net/ethernet/eth.c
> index ed8a3d4..5471cd2 100644
> --- a/net/ethernet/eth.c
> +++ b/net/ethernet/eth.c
> @@ -298,6 +298,14 @@ static int eth_change_mtu(struct net_device *dev, int new_mtu)
>  	return 0;
>  }
>  
> +static int eth_validate_addr(struct net_device *dev)
> +{
> +	if (!is_valid_ether_addr(dev->dev_addr))
> +		return -EINVAL;
> +	
> +	return 0;
> +}

Shouldn't this be "const struct net_device *dev"
