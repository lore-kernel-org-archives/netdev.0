From: "Nithin Nayak Sujir" <nsujir@broadcom.com>
Subject: Re: [PATCH 3/3] tg3: use phylib when robo switch is in use
Date: Tue, 1 Oct 2013 14:12:01 -0700
Message-ID: <524B3AA1.10105@broadcom.com>
References: <1380402928-11480-1-git-send-email-hauke@hauke-m.de>
 <1380402928-11480-3-git-send-email-hauke@hauke-m.de>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=iso-8859-1;
 format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, mchan@broadcom.com, netdev@vger.kernel.org
To: "Hauke Mehrtens" <hauke@hauke-m.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:1936 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751769Ab3JAVM7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 1 Oct 2013 17:12:59 -0400
In-Reply-To: <1380402928-11480-3-git-send-email-hauke@hauke-m.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 09/28/2013 02:15 PM, Hauke Mehrtens wrote:
> When a switch is connected as a PHY to the MAC driven by tg3, use
> phylib and provide the phy address to tg3 from the sprom.
>
> Signed-off-by: Hauke Mehrtens <hauke@hauke-m.de>
> ---

Acked-by: Nithin Nayak Sujir <nsujir@broadcom.com>


>   drivers/net/ethernet/broadcom/tg3.c |   11 ++++++++++-
>   1 file changed, 10 insertions(+), 1 deletion(-)
>
> diff --git a/drivers/net/ethernet/broadcom/tg3.c b/drivers/net/ethernet/broadcom/tg3.c
> index 853a05e..a17a3c9 100644
> --- a/drivers/net/ethernet/broadcom/tg3.c
> +++ b/drivers/net/ethernet/broadcom/tg3.c
> @@ -1513,6 +1513,13 @@ static int tg3_mdio_init(struct tg3 *tp)
>   				    TG3_CPMU_PHY_STRAP_IS_SERDES;
>   		if (is_serdes)
>   			tp->phy_addr += 7;
> +	} else if (tg3_flag(tp, IS_SSB_CORE) && tg3_flag(tp, ROBOSWITCH)) {
> +		int addr;
> +
> +		addr = ssb_gige_get_phyaddr(tp->pdev);
> +		if (addr < 0)
> +			return addr;
> +		tp->phy_addr = addr;
>   	} else
>   		tp->phy_addr = TG3_PHY_MII_ADDR;
>
> @@ -17366,8 +17373,10 @@ static int tg3_init_one(struct pci_dev *pdev,
>   			tg3_flag_set(tp, FLUSH_POSTED_WRITES);
>   		if (ssb_gige_one_dma_at_once(pdev))
>   			tg3_flag_set(tp, ONE_DMA_AT_ONCE);
> -		if (ssb_gige_have_roboswitch(pdev))
> +		if (ssb_gige_have_roboswitch(pdev)) {
> +			tg3_flag_set(tp, USE_PHYLIB);
>   			tg3_flag_set(tp, ROBOSWITCH);
> +		}
>   		if (ssb_gige_is_rgmii(pdev))
>   			tg3_flag_set(tp, RGMII_MODE);
>   	}
>
