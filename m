From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 1/7] mlx4: Adjust QP1 multiplexing for
 RoCE/SRIOV
Date: Mon, 10 Mar 2014 15:50:15 -0400 (EDT)
Message-ID: <20140310.155015.1679111216670234389.davem@davemloft.net>
References: <1394376844-12812-1-git-send-email-ogerlitz@mellanox.com>
	<1394376844-12812-2-git-send-email-ogerlitz@mellanox.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, roland@kernel.org,
	jackm@dev.mellanox.co.il, amirv@mellanox.com
To: ogerlitz@mellanox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:46732 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753019AbaCJTuS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Mar 2014 15:50:18 -0400
In-Reply-To: <1394376844-12812-2-git-send-email-ogerlitz@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Or Gerlitz <ogerlitz@mellanox.com>
Date: Sun,  9 Mar 2014 16:53:58 +0200

> @@ -509,6 +510,10 @@ int mlx4_ib_send_to_slave(struct mlx4_ib_dev *dev, int slave, u8 port,
>  	 * The driver will set the force loopback bit in post_send */
>  	memset(&attr, 0, sizeof attr);
>  	attr.port_num = port;
> +	if (is_eth) {
> +		mlx4_get_roce_gid_from_slave(dev->dev, port, slave, attr.grh.dgid.raw);
> +		attr.ah_flags = IB_AH_GRH;
> +	}
>  	ah = ib_create_ah(tun_ctx->pd, &attr);
>  	if (IS_ERR(ah))
>  		return -ENOMEM;

Either the error returned from mlx4_get_roce_gid_from_slave() doesn't matter...

> +			err = mlx4_get_roce_gid_from_slave(to_mdev(ib_dev)->dev,
> +							   be32_to_cpu(ah->av.ib.port_pd) >> 24,
> +							   ah->av.ib.gid_index, &sgid.raw[0]);
> +			if (err)
> +				return err;

or it does.

Please decide whether it does or not.  If it does, make all call sites check the return
value.  If it does not, remove the return value and make the function return void.
