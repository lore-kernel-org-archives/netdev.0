From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH] Gigabit Ethernet driver of Topcliff PCH
Date: Thu, 26 Aug 2010 08:47:46 -0700
Message-ID: <20100826084746.4fd266f7@nehalam>
References: <4C763A67.5040107@dsn.okisemi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: LKML <linux-kernel@vger.kernel.org>,
	ML netdev <netdev@vger.kernel.org>,
	Greg Rose <gregory.v.rose@intel.com>,
	Maxime Bizon <mbizon@freebox.fr>,
	Kristoffer Glembo <kristoffer@gaisler.com>,
	Ralf Baechle <ralf@linux-mips.org>,
	John Linn <john.linn@xilinx.com>,
	Randy Dunlap <randy.dunlap@oracle.com>,
	"David S. Miller" <davem@davemloft.net>,
	MeeGo <meego-dev@meego.com>, "Wang, Qi" <qi.wang@intel.com>,
	"Wang, Yong Y" <yong.y.wang@intel.com>,
	Andrew <andrew.chih.howe.khor@intel.com>,
	Intel OTC <joel.clark@intel.com>,
	"Foster, Margie" <margie.foster@intel.com>,
	Toshiharu Okada <okada533@dsn.okisemi.com>,
	Tomoya Morinaga <morinaga526@dsn.okisemi.com>,
	Takahiro Shimizu <shimizu394@dsn.okisemi.com>
To: Masayuki Ohtake <masa-korg@dsn.okisemi.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <4C763A67.5040107@dsn.okisemi.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 26 Aug 2010 18:56:55 +0900
Masayuki Ohtake <masa-korg@dsn.okisemi.com> wrote:

> +/**
> + * pch_gbe_alloc_queues - Allocate memory for all rings
> + * @adapter:  Board private structure to initialize
> + * Returns
> + *	0:	Successfully
> + *	Negative value:	Failed
> + */
> +static int pch_gbe_alloc_queues(struct pch_gbe_adapter *adapter)
> +{
> +	int size;
> +
> +	PCH_GBE_DEBUG("%s\n", __func__);
> +
> +
> +	size = (int)sizeof(struct pch_gbe_tx_ring);
> +	adapter->tx_ring = kmalloc(size, GFP_KERNEL);
> +	if (!adapter->tx_ring)
> +		return -ENOMEM;
> +	memset(adapter->tx_ring, 0, size);
> +
> +	size = (int)sizeof(struct pch_gbe_rx_ring);
> +	adapter->rx_ring = kmalloc(size, GFP_KERNEL);
> +	if (!adapter->rx_ring) {
> +		kfree(adapter->tx_ring);
> +		return -ENOMEM;
> +	}
> +	memset(adapter->rx_ring, 0, size);
> +
> +	size = (int)sizeof(struct net_device);
> +	adapter->polling_netdev = kmalloc(size, GFP_KERNEL);
> +	if (!adapter->polling_netdev) {
> +		kfree(adapter->tx_ring);
> +		kfree(adapter->rx_ring);
> +		return -ENOMEM;

This is not allowed, you can not just allocate up a network
device structure out of kmalloc space. Not sure what you are doing
with the polling_netdev?  Is it left over from when net_device
and NAPI were more closely bound?


-- 
