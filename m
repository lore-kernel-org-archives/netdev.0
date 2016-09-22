From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH net-next v2 1/3] net: ethernet: mediatek: add extension of
 phy-mode for TRGMII
Date: Thu, 22 Sep 2016 14:30:53 +0300
Message-ID: <9e375cf6-8283-b6fb-f21f-5d013c3172fa@cogentembedded.com>
References: <1474511636-11644-1-git-send-email-sean.wang@mediatek.com>
 <1474511636-11644-2-git-send-email-sean.wang@mediatek.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: nbd@openwrt.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, linux-mediatek@lists.infradead.org,
        andrew@lunn.ch, f.fainelli@gmail.com, keyhaede@gmail.com,
        objelf@gmail.com
To: sean.wang@mediatek.com, john@phrozen.org, davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1474511636-11644-2-git-send-email-sean.wang@mediatek.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello.

On 9/22/2016 5:33 AM, sean.wang@mediatek.com wrote:

> From: Sean Wang <sean.wang@mediatek.com>
>
> adds PHY-mode "trgmii" as an extension for the operation
> mode of the PHY interface for PHY_INTERFACE_MODE_TRGMII.
> and adds a variable trgmii inside mtk_mac as the indication
> to make the difference between the MAC connected to internal
> switch or connected to external PHY by the given configuration
> on the board and then to perform the corresponding setup on
> TRGMII hardware module.
>
> Signed-off-by: Sean Wang <sean.wang@mediatek.com>
> Cc: Florian Fainelli <f.fainelli@gmail.com>
> ---
>  drivers/net/ethernet/mediatek/mtk_eth_soc.c | 2 ++
>  drivers/net/ethernet/mediatek/mtk_eth_soc.h | 3 +++
>  include/linux/phy.h                         | 3 +++
>  3 files changed, 8 insertions(+)
>
> diff --git a/drivers/net/ethernet/mediatek/mtk_eth_soc.c b/drivers/net/ethernet/mediatek/mtk_eth_soc.c
> index ca6b501..827f4bd 100644
> --- a/drivers/net/ethernet/mediatek/mtk_eth_soc.c
> +++ b/drivers/net/ethernet/mediatek/mtk_eth_soc.c
> @@ -244,6 +244,8 @@ static int mtk_phy_connect(struct mtk_mac *mac)
>  		return -ENODEV;
>
>  	switch (of_get_phy_mode(np)) {
> +	case PHY_INTERFACE_MODE_TRGMII:
> +		mac->trgmii = true;
>  	case PHY_INTERFACE_MODE_RGMII_TXID:
>  	case PHY_INTERFACE_MODE_RGMII_RXID:
>  	case PHY_INTERFACE_MODE_RGMII_ID:
> diff --git a/drivers/net/ethernet/mediatek/mtk_eth_soc.h b/drivers/net/ethernet/mediatek/mtk_eth_soc.h
> index 7c5e534..e3b9525 100644
> --- a/drivers/net/ethernet/mediatek/mtk_eth_soc.h
> +++ b/drivers/net/ethernet/mediatek/mtk_eth_soc.h
> @@ -529,6 +529,8 @@ struct mtk_eth {
>   * @hw:			Backpointer to our main datastruture
>   * @hw_stats:		Packet statistics counter
>   * @phy_dev:		The attached PHY if available
> + * @trgmii		Indicate if the MAC uses TRGMII connected to internal
> +			switch
>   */
>  struct mtk_mac {
>  	int				id;
> @@ -539,6 +541,7 @@ struct mtk_mac {
>  	struct phy_device		*phy_dev;
>  	__be32				hwlro_ip[MTK_MAX_LRO_IP_CNT];
>  	int				hwlro_ip_cnt;
> +	bool				trgmii;

     I don't see where this is used.

[...]
> diff --git a/include/linux/phy.h b/include/linux/phy.h
> index 2d24b28..e25f183 100644
> --- a/include/linux/phy.h
> +++ b/include/linux/phy.h
> @@ -80,6 +80,7 @@ typedef enum {
>  	PHY_INTERFACE_MODE_XGMII,
>  	PHY_INTERFACE_MODE_MOCA,
>  	PHY_INTERFACE_MODE_QSGMII,
> +	PHY_INTERFACE_MODE_TRGMII,
>  	PHY_INTERFACE_MODE_MAX,
>  } phy_interface_t;
>
> @@ -123,6 +124,8 @@ static inline const char *phy_modes(phy_interface_t interface)
>  		return "moca";
>  	case PHY_INTERFACE_MODE_QSGMII:
>  		return "qsgmii";
> +	case PHY_INTERFACE_MODE_TRGMII:
> +		return "trgmii";
>  	default:
>  		return "unknown";
>  	}

    I think this should be done in a separate phylib patch.

MBR, Sergei
