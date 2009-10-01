From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2.6.32-rc1] net: VMware virtual Ethernet NIC driver:
 vmxnet3
Date: Thu, 01 Oct 2009 15:23:55 -0700 (PDT)
Message-ID: <20091001.152355.209105273.davem@davemloft.net>
References: <alpine.LRH.2.00.0909301432410.8073@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	shemminger@linux-foundation.org, jgarzik@pobox.com,
	anthony@codemonkey.ws, chrisw@sous-sol.org, greg@kroah.com,
	akpm@linux-foundation.org,
	virtualization@lists.linux-foundation.org, pv-drivers@vmware.com
To: sbhatewara@vmware.com
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1753487AbZJAWXh@vger.kernel.org>
In-Reply-To: <alpine.LRH.2.00.0909301432410.8073@localhost.localdomain>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Shreyas Bhatewara <sbhatewara@vmware.com>
Date: Wed, 30 Sep 2009 14:34:57 -0700 (PDT)

> +{
> +	struct vmxnet3_adapter *adapter = netdev_priv(netdev);
> +	u8 *base;
> +	int i;
> +
> + VMXNET3_WRITE_BAR1_REG(adapter, VMXNET3_REG_CMD,
> VMXNET3_CMD_GET_STATS);
> +
> +	/* this does assume each counter is 64-bit wide */
> +
> +	base = (u8 *)&adapter->tqd_start->stats;
> +	for (i = 0; i < ARRAY_SIZE(vmxnet3_tq_dev_stats); i++)
> + *buf++ = *(u64 *)(base + vmxnet3_tq_dev_stats[i].offset);
> +
> +	base = (u8 *)&adapter->tx_queue.stats;
> +	for (i = 0; i < ARRAY_SIZE(vmxnet3_tq_driver_stats); i++)
> + *buf++ = *(u64 *)(base + vmxnet3_tq_driver_stats[i].offset);
> +
> +	base = (u8 *)&adapter->rqd_start->stats;

There's a lot of code like this that isn't indented properly.  Either
that or your email client has corrupted the patch by breaking up long
lines or similar.

Another example:

> +static int
> +vmxnet3_set_rx_csum(struct net_device *netdev, u32 val)
> +{
> +	struct vmxnet3_adapter *adapter = netdev_priv(netdev);
> +
> +	if (adapter->rxcsum != val) {
> +		adapter->rxcsum = val;
> +		if (netif_running(netdev)) {
> +			if (val)
> + adapter->shared->devRead.misc.uptFeatures |=
> + UPT1_F_RXCSUM;
> +			else
> + adapter->shared->devRead.misc.uptFeatures &=
> + ~UPT1_F_RXCSUM;
> +
> + VMXNET3_WRITE_BAR1_REG(adapter, VMXNET3_REG_CMD,
> + VMXNET3_CMD_UPDATE_FEATURE);
> +		}
> +	}
> +	return 0;
> +}

Yikes! :-)
