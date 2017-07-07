From: Matthias Brugger <matthias.bgg@gmail.com>
Subject: Re: [PATCH] net: ethernet: mediatek: add NULL check on
 of_match_device() return value
Date: Fri, 7 Jul 2017 16:51:17 +0200
Message-ID: <1eba7874-fd99-e45c-005a-dcc9a3d51538@gmail.com>
References: <20170707071135.GA29205@embeddedgus>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
        linux-mediatek@lists.infradead.org, linux-kernel@vger.kernel.org
To: "Gustavo A. R. Silva" <garsilva@embeddedor.com>,
        Felix Fietkau <nbd@openwrt.org>,
        John Crispin <blogic@openwrt.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170707071135.GA29205@embeddedgus>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



On 07/07/2017 09:11 AM, Gustavo A. R. Silva wrote:
> Check return value from call to of_match_device()
> in order to prevent a NULL pointer dereference.
> 
> In case of NULL print error message and return -ENODEV
> 
> Signed-off-by: Gustavo A. R. Silva <garsilva@embeddedor.com>
> ---

Reviewed-by: Matthias Brugger <matthias.bgg@gmail.com>

>   drivers/net/ethernet/mediatek/mtk_eth_soc.c | 5 +++++
>   1 file changed, 5 insertions(+)
> 
> diff --git a/drivers/net/ethernet/mediatek/mtk_eth_soc.c b/drivers/net/ethernet/mediatek/mtk_eth_soc.c
> index adaaafc..6a77dea 100644
> --- a/drivers/net/ethernet/mediatek/mtk_eth_soc.c
> +++ b/drivers/net/ethernet/mediatek/mtk_eth_soc.c
> @@ -2408,6 +2408,11 @@ static int mtk_probe(struct platform_device *pdev)
>   	int i;
>   
>   	match = of_match_device(of_mtk_match, &pdev->dev);
> +	if (!match) {
> +		dev_err(&pdev->dev, "failed to match device\n");
> +		return -ENODEV;
> +	}
> +
>   	soc = (struct mtk_soc_data *)match->data;
>   
>   	eth = devm_kzalloc(&pdev->dev, sizeof(*eth), GFP_KERNEL);
> 
