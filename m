From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH] seastar - SeaStar Ethernet driver
Date: Tue, 2 Feb 2010 15:38:04 -0800
Message-ID: <20100202153804.6aa49835@nehalam>
References: <20100202205845.GE5246@hawkeye.sandia.gov>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: "Kevin Pedretti" <ktpedre@sandia.gov>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20100202205845.GE5246@hawkeye.sandia.gov>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2 Feb 2010 13:58:45 -0700
"Kevin Pedretti" <ktpedre@sandia.gov> wrote:

> +
> +static const struct net_device_ops ss_netdev_ops = {
> +	.ndo_open		= ss_open,
> +	.ndo_start_xmit		= ss_tx,
> +	.ndo_set_mac_address	= eth_mac_addr,
> +};

You should have a validate_address as well.
> +
> +
> +static const struct header_ops ss_header_ops = {
> +	.create			= ss_header_create,
> +};
> +
> +
> +static void ss_ht_irq_update(struct pci_dev *dev, int irq,
> +			     struct ht_irq_msg *msg)
> +{
> +	seastar_setup_htb_bi(msg->address_lo);
> +}
> +
> +
> +static int __devinit ss_probe(struct pci_dev *pdev,
> +			      const struct pci_device_id *id)
> +{
> +	struct net_device *netdev;
> +	struct ss_priv *ssp;
> +	int i, irq, err = 0;
> +
> +	err = pci_enable_device(pdev);
> +	if (err != 0) {
> +		dev_err(&pdev->dev, "Could not enable PCI device.\n");
> +		return -ENODEV;
> +	}
> +
> +	netdev = alloc_etherdev(sizeof(*ssp));
> +	if (netdev == NULL) {
> +		dev_err(&pdev->dev, "Could not allocate ethernet device.\n");
> +		return -ENOMEM;
> +	}

You may want to use alloc_netdev() since this starts to look
like a non-ethernet device.
> +
> +	SET_NETDEV_DEV(netdev, &pdev->dev);
> +
> +	strcpy(netdev->name, "ss");
> +	netdev->netdev_ops	= &ss_netdev_ops;
> +	netdev->header_ops	= &ss_header_ops;
> +	netdev->mtu		= 16000;
> +	netdev->flags		= IFF_NOARP;
> +
> +	/* Setup private state */
> +	ssp = netdev_priv(netdev);
> +	memset(ssp, 0, sizeof(*ssp));

memset is unnecessary, since alloc_netdev/alloc_etherdev zero that area
already.
-- 
