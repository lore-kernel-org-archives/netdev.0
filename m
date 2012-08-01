From: "Dmitry Kravkov" <dmitry@broadcom.com>
Subject: Re: [PATCH] bnx2x: fix mem leak when command is unknown
Date: Wed, 1 Aug 2012 10:41:17 +0300
Message-ID: <1343806877.834.3.camel@lb-tlvb-dmitry.il.broadcom.com>
References: <alpine.LNX.2.00.1207312337590.7100@swampdragon.chaosbits.net>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: "Eilon Greenstein" <eilong@broadcom.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: "Jesper Juhl" <jj@chaosbits.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <alpine.LNX.2.00.1207312337590.7100@swampdragon.chaosbits.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2012-07-31 at 23:39 +0200, Jesper Juhl wrote:
> In bnx2x_mcast_enqueue_cmd() we'll leak the memory allocated to
> 'new_cmd' if we hit the deafault case of the 'switch (cmd)'.
> Add a 'kfree(new_cmd)' to that case to avoid the leak.
> 
> Signed-off-by: Jesper Juhl <jj@chaosbits.net>
> ---
>  drivers/net/ethernet/broadcom/bnx2x/bnx2x_sp.c | 1 +
>  1 file changed, 1 insertion(+)
> 
>   note: due to lack of hardware this patch is compile tested only.
> 
> diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_sp.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_sp.c
> index 734fd87..62f754b 100644
> --- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_sp.c
> +++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_sp.c
> @@ -2485,6 +2485,7 @@ static int bnx2x_mcast_enqueue_cmd(struct bnx2x *bp,
>  		break;
>  
>  	default:
> +		kfree(new_cmd);
>  		BNX2X_ERR("Unknown command: %d\n", cmd);
>  		return -EINVAL;
>  	}
> -- 
> 1.7.11.3
> 
Thanks a lot, Jesper.

Acked-by: Dmitry Kravkov <dmitry@broadcom.com>
> 
