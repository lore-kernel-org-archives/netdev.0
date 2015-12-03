From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH net-next] ravb: ptp: Add CONFIG mode support
Date: Fri, 4 Dec 2015 00:09:29 +0300
Message-ID: <5660AF89.1010008@cogentembedded.com>
References: <1448989479-11594-1-git-send-email-ykaneko0929@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Simon Horman <horms@verge.net.au>,
	Magnus Damm <magnus.damm@gmail.com>, linux-sh@vger.kernel.org
To: Yoshihiro Kaneko <ykaneko0929@gmail.com>, netdev@vger.kernel.org
Return-path: <linux-sh-owner@vger.kernel.org>
In-Reply-To: <1448989479-11594-1-git-send-email-ykaneko0929@gmail.com>
Sender: linux-sh-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello.

On 12/01/2015 08:04 PM, Yoshihiro Kaneko wrote:

> From: Kazuya Mizuguchi <kazuya.mizuguchi.ks@renesas.com>
>
> This patch makes PTP support active in CONFIG mode on R-Car Gen3.
>
> Signed-off-by: Kazuya Mizuguchi <kazuya.mizuguchi.ks@renesas.com>
> Signed-off-by: Yoshihiro Kaneko <ykaneko0929@gmail.com>
> ---
>
> This patch is based on the master branch of David Miller's next networking
> tree.
>
>   drivers/net/ethernet/renesas/ravb.h      |  1 +
>   drivers/net/ethernet/renesas/ravb_main.c | 33 +++++++++++++++++++++++++++-----
>   2 files changed, 29 insertions(+), 5 deletions(-)
>
> diff --git a/drivers/net/ethernet/renesas/ravb.h b/drivers/net/ethernet/renesas/ravb.h
> index f9dee74..9fbe92a 100644
> --- a/drivers/net/ethernet/renesas/ravb.h
> +++ b/drivers/net/ethernet/renesas/ravb.h
> @@ -206,6 +206,7 @@ enum CCC_BIT {
>   	CCC_OPC_RESET	= 0x00000000,
>   	CCC_OPC_CONFIG	= 0x00000001,
>   	CCC_OPC_OPERATION = 0x00000002,
> +	CCC_GAC		= 0x00000080,

    I'd have added a comment that it's gen3 specific.

[...]
> diff --git a/drivers/net/ethernet/renesas/ravb_main.c b/drivers/net/ethernet/renesas/ravb_main.c
> index 990dc55..293046d 100644
> --- a/drivers/net/ethernet/renesas/ravb_main.c
> +++ b/drivers/net/ethernet/renesas/ravb_main.c
[...]
> @@ -1814,6 +1825,10 @@ static int ravb_probe(struct platform_device *pdev)
>   	/* Initialise HW timestamp list */
>   	INIT_LIST_HEAD(&priv->ts_skb_list);
>
> +	/* Initialise PTP Clock driver */
> +	if (chip_id != RCAR_GEN2)
> +		ravb_ptp_init(ndev, pdev);
> +
>   	/* Debug message level */
>   	priv->msg_enable = RAVB_DEF_MSG_ENABLE;
>
> @@ -1855,6 +1870,10 @@ out_napi_del:
>   out_dma_free:
>   	dma_free_coherent(ndev->dev.parent, priv->desc_bat_size, priv->desc_bat,
>   			  priv->desc_bat_dma);
> +
> +	/* Stop PTP Clock driver */
> +	if (chip_id != RCAR_GEN2)
> +		ravb_ptp_stop(ndev);

    This is clearly misplaced.

[...]

MBR, Sergei

