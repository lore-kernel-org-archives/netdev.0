From: Oliver Hartkopp <oliver@hartkopp.net>
Subject: Re: [PATCH]: Third (final?) release of Sun Neptune driver
Date: Mon, 08 Oct 2007 18:04:15 +0200
Message-ID: <470A54FF.20705@hartkopp.net>
References: <20071005.031209.57156822.davem@davemloft.net>	<200710051846.19965.netdev@axxeo.de>	<200710051849.50091.netdev@axxeo.de> <20071005.170849.78481094.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mo-p00-ob.rzone.de ([81.169.146.160]:25410 "EHLO
	mo-p00-ob.rzone.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750844AbXJHQES (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Oct 2007 12:04:18 -0400
In-Reply-To: <20071005.170849.78481094.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David Miller wrote:
>  	if (err < 0)
> -		return err;
> +		goto out_err;
>  
>  	if (err != (PHYXS_XGXS_LANE_STAT_ALINGED |
>  		    PHYXS_XGXS_LANE_STAT_MAGIC |
> @@ -1133,6 +1133,10 @@ out:
>  
>  	*link_up_p = link_up;
>  	return 0;
> +
> +out_err:
> +	spin_unlock_irqrestore(&np->lock, flags);
> +	return err;
>  }
>  
>  static int link_status_1g(struct niu *np, int *link_up_p)
>   

Should *link_up_p be set to any valid value in the out_err case in 
link_status_10g()?

Oliver
