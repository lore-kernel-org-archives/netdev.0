From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] Gigabit Ethernet driver of Topcliff PCH
Date: Wed, 08 Sep 2010 13:36:27 -0700 (PDT)
Message-ID: <20100908.133627.70178420.davem@davemloft.net>
References: <4C81019E.1010808@dsn.okisemi.com>
	<4C85A6AD.9080301@dsn.okisemi.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: randy.dunlap@oracle.com, ralf@linux-mips.org,
	eric.dumazet@gmail.com, netdev@vger.kernel.org,
	meego-dev@meego.com, mbizon@freebox.fr,
	linux-kernel@vger.kernel.org, kristoffer@gaisler.com,
	john.linn@xilinx.com, joe@perches.com, gregory.v.rose@intel.com,
	yong.y.wang@intel.com, qi.wang@intel.com, okada533@dsn.okisemi.com,
	morinaga526@dsn.okisemi.com, shimizu394@dsn.okisemi.com,
	joel.clark@intel.com, margie.foster@intel.com,
	andrew.chih.howe.khor@intel.com
To: masa-korg@dsn.okisemi.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <4C85A6AD.9080301@dsn.okisemi.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Masayuki Ohtake <masa-korg@dsn.okisemi.com>
Date: Tue, 07 Sep 2010 11:42:53 +0900

> +/**
> + * pch_gbe_clean_rx - Send received data up the network stack; legacy
> + * @adapter:     Board private structure
> + * @rx_ring:     Rx descriptor ring
> + * @work_done:   Completed count
> + * @work_to_do:  Request count
> + * Returns
> + *	true:  Cleaned the descriptor
> + *	false: Not cleaned the descriptor
> + */
> +static bool
> +pch_gbe_clean_rx(struct pch_gbe_adapter *adapter,
> +		 struct pch_gbe_rx_ring *rx_ring,
> +		 int *work_done, int work_to_do)
> +{
..
> +			if (netif_receive_skb(skb) == NET_RX_DROP) {
> +				adapter->stats.rx_dropped++;

pch_gbe_clean_rx() should be given the "napi_struct" pointer
argument from it's caller, and packets should be given to the
stack using napi_gro_receive().  Finally, NETIF_F_GRO should
be set in netdev->flags at probe time.

Also, you should not use the return value of netif_receive_skb() to
bump the standard rx_dropped statistics value, those return code are
for other purposes.  No other driver does what you are doing with this
return value.

If you wish to increment some extended stastic value (like
drivers/net/gianfar.c does) with another name, that's fine.
