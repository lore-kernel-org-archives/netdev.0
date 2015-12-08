From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH net-next] ravb: ptp: fix misplaced ravb_ptp_stop() calling
 in ravb_probe()
Date: Tue, 8 Dec 2015 22:06:38 +0300
Message-ID: <56672A3E.7020908@cogentembedded.com>
References: <1449599969-20628-1-git-send-email-ykaneko0929@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Simon Horman <horms@verge.net.au>,
	Magnus Damm <magnus.damm@gmail.com>, linux-sh@vger.kernel.org
To: Yoshihiro Kaneko <ykaneko0929@gmail.com>, netdev@vger.kernel.org
Return-path: <linux-sh-owner@vger.kernel.org>
In-Reply-To: <1449599969-20628-1-git-send-email-ykaneko0929@gmail.com>
Sender: linux-sh-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello.

On 12/08/2015 09:39 PM, Yoshihiro Kaneko wrote:

> 'commit <f5d7837f96e5> ("ravb: ptp: Add CONFIG mode support")' added

    Please run your patches thru scripts/checkpatch.pl -- it now enforces 
certain format of the commit citing: no need for '' and <> there.

> a calling of ravb_ptp_stop() in a wrong place in ravb_probe().
>
> Signed-off-by: Yoshihiro Kaneko <ykaneko0929@gmail.com>
> ---
>
> This patch is based on the master branch of David Miller's next networking
> tree.
>
> Compile tested only.
>
>   drivers/net/ethernet/renesas/ravb_main.c | 6 +++---
>   1 file changed, 3 insertions(+), 3 deletions(-)
>
> diff --git a/drivers/net/ethernet/renesas/ravb_main.c b/drivers/net/ethernet/renesas/ravb_main.c
> index 1cf1226..93be519 100644
> --- a/drivers/net/ethernet/renesas/ravb_main.c
> +++ b/drivers/net/ethernet/renesas/ravb_main.c
> @@ -1875,12 +1875,12 @@ out_napi_del:
>   	netif_napi_del(&priv->napi[RAVB_BE]);
>   	ravb_mdio_release(priv);
>   out_dma_free:
> -	dma_free_coherent(ndev->dev.parent, priv->desc_bat_size, priv->desc_bat,
> -			  priv->desc_bat_dma);
> -
>   	/* Stop PTP Clock driver */
>   	if (chip_id != RCAR_GEN2)
>   		ravb_ptp_stop(ndev);
> +
> +	dma_free_coherent(ndev->dev.parent, priv->desc_bat_size, priv->desc_bat,
> +			  priv->desc_bat_dma);

    This is a joke, right? Because this doesn't really change anything. ;-)
Actually, I've just looked at the code once again, and I have to take back my 
former comment about this code being misplaced -- I thought it should be under 
a different label, if not under a separate label and I was wrong.
    BUT... I think you missed some calls of ravb_ptp_{init|stop}() which are 
not necessary on gen3 SoCs. Namely, in ravb_set_ringparam() and 
ravb_tx_timeout_work()...

MBR, Sergei

