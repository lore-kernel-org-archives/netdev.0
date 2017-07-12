From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH net 20/20] net/hinic: Add ethtool and stats
Date: Wed, 12 Jul 2017 17:43:47 +0200
Message-ID: <20170712154347.GH2557@lunn.ch>
References: <cover.1499865197.git.aviad.krawczyk@huawei.com>
 <bd60f835144c37334a53df6a053b7efcc4c26c41.1499865198.git.aviad.krawczyk@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, linux-kernel@vger.kernel.org,
        netdev@vger.kernel.org, bc.y@huawei.com, victor.gissin@huawei.com,
        zhaochen6@huawei.com, tony.qu@huawei.com
To: Aviad Krawczyk <aviad.krawczyk@huawei.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <bd60f835144c37334a53df6a053b7efcc4c26c41.1499865198.git.aviad.krawczyk@huawei.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Jul 12, 2017 at 10:17:26PM +0800, Aviad Krawczyk wrote:

Hi Avaid

> +
> +static void hinic_tx_timeout(struct net_device *netdev)
> +{
> +	struct hinic_dev *nic_dev = netdev_priv(netdev);
> +
> +	netif_err(nic_dev, drv, netdev, "Tx timeout\n");
> +}
> +
> +#ifdef CONFIG_NET_POLL_CONTROLLER
> +static void hinic_netpoll(struct net_device *netdev)
> +{
> +	struct hinic_dev *nic_dev = netdev_priv(netdev);
> +	struct hinic_hwdev *hwdev = nic_dev->hwdev;
> +	int i, num_qps = hinic_hwdev_num_qps(hwdev);
> +
> +	for (i = 0; i < num_qps; i++) {
> +		struct hinic_txq *txq = &nic_dev->txqs[i];
> +		struct hinic_rxq *rxq = &nic_dev->rxqs[i];
> +
> +		napi_schedule(&txq->napi);
> +		napi_schedule(&rxq->napi);
> +	}
> +}
> +#endif

This has nothing to do with ethtool support. Separate patch please.

     Andrew
