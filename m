From: Sarveshwar Bandi <sarveshwarb@serverengines.com>
Subject: Re: [patch 1/2] be2net: add unlock on error path
Date: Thu, 27 May 2010 12:01:57 +0530
Message-ID: <20100527063156.GA12380@serverengines.com>
References: <20100526144634.GL22515@bicker>
Reply-To: Sarveshwar Bandi <sarveshwarb@serverengines.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Sathya Perla <sathyap@serverengines.com>,
	Subbu Seetharaman <subbus@serverengines.com>,
	Ajit Khaparde <ajitk@serverengines.com>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	kernel-janitors@vger.kernel.org
To: Dan Carpenter <error27@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from segment-124-30.sify.net ([124.30.166.146]:54860 "EHLO
	akhaparde.serverengines.com" rhost-flags-OK-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S1750979Ab0E0Gb5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 May 2010 02:31:57 -0400
Content-Disposition: inline
In-Reply-To: <20100526144634.GL22515@bicker>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Thanks

Acked-by: Sarveshwar Bandi <sarveshwarb@serverengines.com> 
On 26/05/10 16:46 +0200, Dan Carpenter wrote:
> The unlock accidentally got removed from the error path in dd131e76e5:
> "be2net: Bug fix to avoid disabling bottom half during firmware upgrade."
>
> Signed-off-by: Dan Carpenter <error27@gmail.com>
> 
> diff --git a/drivers/net/benet/be_cmds.c b/drivers/net/benet/be_cmds.c
> index c911bfb..18d5789 100644
> --- a/drivers/net/benet/be_cmds.c
> +++ b/drivers/net/benet/be_cmds.c
> @@ -1429,7 +1429,7 @@ int be_cmd_write_flashrom(struct be_adapter *adapter, struct be_dma_mem *cmd,
>  	wrb = wrb_from_mccq(adapter);
>  	if (!wrb) {
>  		status = -EBUSY;
> -		goto err;
> +		goto err_unlock;
>  	}
>  	req = cmd->va;
>  	sge = nonembedded_sgl(wrb);
> @@ -1457,7 +1457,10 @@ int be_cmd_write_flashrom(struct be_adapter *adapter, struct be_dma_mem *cmd,
>  	else
>  		status = adapter->flash_status;
>  
> -err:
> +	return status;
> +
> +err_unlock:
> +	spin_unlock_bh(&adapter->mcc_lock);
>  	return status;
>  }
>  
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
