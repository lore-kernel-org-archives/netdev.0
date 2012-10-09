From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH V1 2/3] net/mlx4_core: Read HCA frequency and map
 internal clock
Date: Tue, 09 Oct 2012 09:54:21 -0700
Message-ID: <1349801661.2386.8.camel@joe-AO722>
References: <1349796013-31106-1-git-send-email-ogerlitz@mellanox.com>
	 <1349796013-31106-3-git-send-email-ogerlitz@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	Eugenia Emantayev <eugenia@mellanox.com>
To: Or Gerlitz <ogerlitz@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from perches-mx.perches.com ([206.117.179.246]:53155 "EHLO
	labridge.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751208Ab2JIQyW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 9 Oct 2012 12:54:22 -0400
In-Reply-To: <1349796013-31106-3-git-send-email-ogerlitz@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2012-10-09 at 17:20 +0200, Or Gerlitz wrote:
> Read HCA frequency, read PCI clock bar and offset, map internal clock to PCI bar.

trivial comments below:

> diff --git a/drivers/net/ethernet/mellanox/mlx4/main.c b/drivers/net/ethernet/mellanox/mlx4/main.c
[]
> @@ -1193,8 +1195,31 @@ static void unmap_bf_area(struct mlx4_dev *dev)
>  		io_mapping_free(mlx4_priv(dev)->bf_mapping);
>  }
>  
> +static int map_internal_clock(struct mlx4_dev *dev)
> +{
> +	struct mlx4_priv *priv = mlx4_priv(dev);
> +
> +	priv->clock_mapping = ioremap(pci_resource_start(dev->pdev,
> +				priv->fw.clock_bar) +
> +				priv->fw.clock_offset, MLX4_CLOCK_SIZE);

I think this is misleading indentation style.
Perhaps this'd be nicer as something like:

	priv->clock_mapping =
		ioremap(pci_resource_start(dev->pdev, priv->fw.clock_bar) +
			priv->fw.clock_offset, MLX4_CLOCK_SIZE);

[]

> +			/* In case we got HCA frequency 0 - disable timestamping
> +			 * to avoid dividing by zero
> +			 */
> +			if (!dev->caps.hca_core_clock) {
> +				dev->caps.flags2 &= ~MLX4_DEV_CAP_FLAG2_TS;
> +				mlx4_err(dev, "HCA frequency is 0. " \
> +					 "Timestamping is not supported.");

These are missing terminating newlines.
Please don't split format strings like this.  It's hard to grep.
Especially please don't use unnecessary line continuations.
The compiler will concatenate these strings without the \.
