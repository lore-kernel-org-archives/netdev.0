From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH V2 net-next 1/8] net: hns3: Add support of HNS3 Ethernet
 Driver for hip08 SoC
Date: Mon, 19 Jun 2017 08:48:01 -0700
Message-ID: <20170619084801.7920e30d@xeon-e3>
References: <20170613231035.494020-1-salil.mehta@huawei.com>
        <20170613231035.494020-2-salil.mehta@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: <davem@davemloft.net>, <yisen.zhuang@huawei.com>,
        <huangdaode@hisilicon.com>, <lipeng321@huawei.com>,
        <mehta.salil.lnk@gmail.com>, <netdev@vger.kernel.org>,
        <linux-kernel@vger.kernel.org>, <linuxarm@huawei.com>
To: Salil Mehta <salil.mehta@huawei.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170613231035.494020-2-salil.mehta@huawei.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 14 Jun 2017 00:10:28 +0100
Salil Mehta <salil.mehta@huawei.com> wrote:

> +hns3_nic_get_stats64(struct net_device *ndev, struct rtnl_link_stats64 *stats)
> +{
> +	struct hns3_nic_priv *priv = netdev_priv(ndev);
> +	int queue_num = priv->ae_handle->kinfo.num_tqps;
> +	u64 tx_bytes = 0;
> +	u64 rx_bytes = 0;
> +	u64 tx_pkts = 0;
> +	u64 rx_pkts = 0;
> +	int idx = 0;
unnecessary initialization

> +
> +	for (idx = 0; idx < queue_num; idx++) {
> +		tx_bytes += priv->ring_data[idx].ring->stats.tx_bytes;
> +		tx_pkts += priv->ring_data[idx].ring->stats.tx_pkts;
> +		rx_bytes +=
> +			priv->ring_data[idx + queue_num].ring->stats.rx_bytes;
> +		rx_pkts += priv->ring_data[idx + queue_num].ring->stats.rx_pkts;
> +	}
> +

Since rx_bytes and other statistics are 64 bit values. You need to use
something to ensure that updates to these values are atomic on 32 bit
platforms.  The most common way to handle this is with the u64_stats_sync
mechanism which is a nop on 64 bit architectures, and uses a seqcount
to do updates on 32 bit CPU's.

  
