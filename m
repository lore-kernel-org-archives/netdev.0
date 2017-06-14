From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH V2 net-next 7/8] net: hns3: Add Ethtool support to HNS3
 driver
Date: Wed, 14 Jun 2017 04:32:28 +0200
Message-ID: <20170614023228.GA16215@lunn.ch>
References: <20170613231035.494020-1-salil.mehta@huawei.com>
 <20170613231035.494020-8-salil.mehta@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, yisen.zhuang@huawei.com,
        huangdaode@hisilicon.com, lipeng321@huawei.com,
        mehta.salil.lnk@gmail.com, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, linuxarm@huawei.com
To: Salil Mehta <salil.mehta@huawei.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20170613231035.494020-8-salil.mehta@huawei.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> +static const struct hns3_link_mode_mapping hns3_lm_map[] = {
> +	{HNS3_LM_FIBRE_BIT, ETHTOOL_LINK_MODE_FIBRE_BIT},
> +	{HNS3_LM_AUTONEG_BIT, ETHTOOL_LINK_MODE_Autoneg_BIT},
> +	{HNS3_LM_TP_BIT, ETHTOOL_LINK_MODE_TP_BIT},
> +	{HNS3_LM_PAUSE_BIT, ETHTOOL_LINK_MODE_Pause_BIT},
> +	{HNS3_LM_BACKPLANE_BIT, ETHTOOL_LINK_MODE_Backplane_BIT},
> +	{HNS3_LM_10BASET_HALF_BIT, ETHTOOL_LINK_MODE_10baseT_Half_BIT},
> +	{HNS3_LM_10BASET_FULL_BIT, ETHTOOL_LINK_MODE_10baseT_Full_BIT},
> +	{HNS3_LM_100BASET_HALF_BIT, ETHTOOL_LINK_MODE_100baseT_Half_BIT},
> +	{HNS3_LM_100BASET_FULL_BIT, ETHTOOL_LINK_MODE_100baseT_Full_BIT},
> +	{HNS3_LM_1000BASET_FULL_BIT, ETHTOOL_LINK_MODE_1000baseT_Full_BIT},
> +	{HNS3_LM_10000BASEKR_FULL_BIT, ETHTOOL_LINK_MODE_10000baseKR_Full_BIT},
> +	{HNS3_LM_25000BASEKR_FULL_BIT, ETHTOOL_LINK_MODE_25000baseKR_Full_BIT},
> +	{HNS3_LM_40000BASELR4_FULL_BIT,
> +	 ETHTOOL_LINK_MODE_40000baseLR4_Full_BIT},
> +	{HNS3_LM_50000BASEKR2_FULL_BIT,
> +	 ETHTOOL_LINK_MODE_50000baseKR2_Full_BIT},
> +	{HNS3_LM_100000BASEKR4_FULL_BIT,
> +	 ETHTOOL_LINK_MODE_100000baseKR4_Full_BIT},
> +};

I don't see anywhere your HNS3_LM_ enum's get used by the hardware. So
it would be better to just use the Linux values and avoid this translation macro:

> +
> +#define HNS3_DRV_TO_ETHTOOL_CAPS(caps, lk_ksettings, name)	\
> +{								\
> +	int i;							\
> +								\
> +	for (i = 0; i < ARRAY_SIZE(hns3_lm_map); i++) {		\
> +		if ((caps) & hns3_lm_map[i].hns3_link_mode)	\
> +			__set_bit(hns3_lm_map[i].ethtool_link_mode,\
> +				  (lk_ksettings)->link_modes.name); \
> +	}							\
> +}

	Andrew
