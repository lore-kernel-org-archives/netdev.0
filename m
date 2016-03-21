From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net 06/10] net: hns: fix return value of the function
 about rss
Date: Mon, 21 Mar 2016 11:42:38 -0400 (EDT)
Message-ID: <20160321.114238.1469581550499984000.davem@davemloft.net>
References: <1458558401-190165-1-git-send-email-Yisen.Zhuang@huawei.com>
	<1458558401-190165-7-git-send-email-Yisen.Zhuang@huawei.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: yankejian@huawei.com, huangdaode@hisilicon.com,
	salil.mehta@huawei.com, lisheng011@huawei.com,
	lipeng321@huawei.com, liguozhu@huawei.com, arnd@arndb.de,
	xieqianqian@huawei.com, andrew@lunn.ch, ivecera@redhat.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	linuxarm@huawei.com
To: Yisen.Zhuang@huawei.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1458558401-190165-7-git-send-email-Yisen.Zhuang@huawei.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Yisen Zhuang <Yisen.Zhuang@huawei.com>
Date: Mon, 21 Mar 2016 19:06:37 +0800

> diff --git a/drivers/net/ethernet/hisilicon/hns/hns_ethtool.c b/drivers/net/ethernet/hisilicon/hns/hns_ethtool.c
> index 3c4a3bc..f3a5e05 100644
> --- a/drivers/net/ethernet/hisilicon/hns/hns_ethtool.c
> +++ b/drivers/net/ethernet/hisilicon/hns/hns_ethtool.c
 ...
> @@ -1235,12 +1226,11 @@ hns_set_rss(struct net_device *netdev, const u32 *indir, const u8 *key,
>  {
>  	struct hns_nic_priv *priv = netdev_priv(netdev);
>  	struct hnae_ae_ops *ops;
> -	int ret;
>  
>  	if (AE_IS_VER1(priv->enet_ver)) {
>  		netdev_err(netdev,
>  			   "RSS feature is not supported on this hardware\n");
> -		return -EOPNOTSUPP;
> +		return (u32)-EOPNOTSUPP;
>  	}
>  

This is incredibly broken, you cannot cast this negative error return value to
an unsigned integer.
