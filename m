From: Stanislaw Gruszka <sgruszka@redhat.com>
Subject: Re: [v3 Patch 2/2] mlx4: add dynamic LRO disable support
Date: Fri, 18 Jun 2010 13:09:11 +0200
Message-ID: <20100618110910.GA4347@dhcp-lab-161.englab.brq.redhat.com>
References: <20100618105935.6496.4725.sendpatchset@localhost.localdomain> <20100618105945.6496.67648.sendpatchset@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, nhorman@redhat.com, herbert.xu@redhat.com,
	bhutchings@solarflare.com, Ramkrishna.Vepa@exar.com,
	davem@davemloft.net
To: Amerigo Wang <amwang@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:42597 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758357Ab0FRLKb (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 18 Jun 2010 07:10:31 -0400
Content-Disposition: inline
In-Reply-To: <20100618105945.6496.67648.sendpatchset@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jun 18, 2010 at 06:55:38AM -0400, Amerigo Wang wrote:
> +static int mlx4_ethtool_op_set_flags(struct net_device *dev, u32 data)
> +{
> +	struct mlx4_en_priv *priv = netdev_priv(dev);
> +	struct mlx4_en_dev *mdev = priv->mdev;
> +	int rc = 0;
> +	int changed = 0;
> +
> +	if (data & (ETH_FLAG_NTUPLE | ETH_FLAG_RXHASH))
> +		return -EOPNOTSUPP;
> +
> +	if (data & ETH_FLAG_LRO) {
> +		if (!(dev->features & NETIF_F_LRO))
> +			changed = 1;
> +	} else if (dev->features & NETIF_F_LRO) {
> +		changed = 1;
> +		mdev->profile.num_lro = 0;

Everything fine except that, what for you zero num_lro value?

If we set it to zero it will stay zero and we will not create
proper number of lro descriptors in mlx4_en_create_rx_ring()
(called from mlx4_en_set_ringparam() ->  mlx4_en_alloc_resources())
when someone enable LRO again on.

Stanislaw
