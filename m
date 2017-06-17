From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH V3 net-next 1/8] net: hns3: Add support of HNS3 Ethernet
 Driver for hip08 SoC
Date: Sat, 17 Jun 2017 19:54:18 +0200
Message-ID: <20170617175418.GB1974@lunn.ch>
References: <20170617172431.177044-1-salil.mehta@huawei.com>
 <20170617172431.177044-2-salil.mehta@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, yisen.zhuang@huawei.com,
        huangdaode@hisilicon.com, lipeng321@huawei.com,
        mehta.salil.lnk@gmail.com, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, linuxarm@huawei.com
To: Salil Mehta <salil.mehta@huawei.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20170617172431.177044-2-salil.mehta@huawei.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> +static int hns3_nic_net_up(struct net_device *ndev)
> +{
> +	struct hns3_nic_priv *priv = netdev_priv(ndev);
> +	struct hnae3_handle *h = priv->ae_handle;
> +	int i, j;
> +	int ret;
> +
> +	ret = hns3_nic_init_irq(priv);
> +	if (ret != 0) {

  	if (ret)

No need to compare with zero.

> +		netdev_err(ndev, "hns init irq failed! ret=%d\n", ret);
> +		return ret;

> +static int hns3_nic_net_open(struct net_device *ndev)
> +{
> +	struct hns3_nic_priv *priv = netdev_priv(ndev);
> +	struct hnae3_handle *h = priv->ae_handle;
> +	int ret;
> +
> +	netif_carrier_off(ndev);
> +
> +	ret = netif_set_real_num_tx_queues(ndev, h->kinfo.num_tqps);
> +	if (ret < 0) {
> +		netdev_err(ndev, "netif_set_real_num_tx_queues fail, ret=%d!\n",
> +			   ret);
> +		return ret;
> +	}

In general, functions return 0 for success, and something else for an
error. So there is no need to do a comparison. Please remove all
comparisons, unless it is really needed. It also makes the code look
consistent. At the moment you sometime have < 0, sometime !=0, and
sometimes no comparison at all.

	  Andrew
