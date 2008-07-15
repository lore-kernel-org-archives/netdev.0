From: Roland Dreier <rdreier@cisco.com>
Subject: Re: [PATCH RFC 01/10] mlx4_en: Include file
Date: Tue, 15 Jul 2008 12:25:34 -0700
Message-ID: <adaod4zdk5t.fsf@cisco.com>
References: <487B6569.5000806@mellanox.co.il>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jeff@garzik.org, netdev@vger.kernel.org,
	Liran Liss <liranl@mellanox.co.il>, tziporet@mellanox.co.il
To: Yevgeny Petrilin <yevgenyp@mellanox.co.il>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sj-iport-1.cisco.com ([171.71.176.70]:18300 "EHLO
	sj-iport-1.cisco.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756308AbYGOTbs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Jul 2008 15:31:48 -0400
In-Reply-To: <487B6569.5000806@mellanox.co.il> (Yevgeny Petrilin's message of
	"Mon, 14 Jul 2008 17:40:41 +0300")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

 > +enum mlx4_en_access_flags {
 > +	MLX4_EN_ACCESS_LOCAL_WRITE	= 1,
 > +	MLX4_EN_ACCESS_REMOTE_WRITE	= (1<<1),
 > +	MLX4_EN_ACCESS_REMOTE_READ	= (1<<2),
 > +	MLX4_EN_ACCESS_REMOTE_ATOMIC	= (1<<3),
 > +	MLX4_EN_ACCESS_MW_BIND		= (1<<4)
 > +};
 > 
 > +static u32 convert_access(int acc)
 > +{
 > +	return (acc & MLX4_EN_ACCESS_REMOTE_ATOMIC ? MLX4_PERM_ATOMIC       : 0) |
 > +	       (acc & MLX4_EN_ACCESS_REMOTE_WRITE  ? MLX4_PERM_REMOTE_WRITE : 0) |
 > +	       (acc & MLX4_EN_ACCESS_REMOTE_READ   ? MLX4_PERM_REMOTE_READ  : 0) |
 > +	       (acc & MLX4_EN_ACCESS_LOCAL_WRITE   ? MLX4_PERM_LOCAL_WRITE  : 0) |
 > +	       MLX4_PERM_LOCAL_READ;
 > +}
 > +
 > +int mlx4_en_get_dma_mr(struct mlx4_en_dev *mdev, int acc)
 > +{
 > +	int err;
 > +
 > +	err = mlx4_mr_alloc(mdev->dev, mdev->priv_pdn, 0, ~0ull,
 > +			    convert_access(acc), 0, 0, &mdev->mr);
 > +	if (err)
 > +		return err;
 > +
 > +	err = mlx4_mr_enable(mdev->dev, &mdev->mr);
 > +	if (err)
 > +		goto err_mr;
 > +
 > +	return 0;
 > +
 > +err_mr:
 > +	mlx4_mr_free(mdev->dev, &mdev->mr);
 > +	return err;
 > +}

I don't think you need all this access permission stuff, given that you
only have a single call to mlx4_en_get_dma_mr():

 > +	if (mlx4_en_get_dma_mr(mdev, MLX4_EN_ACCESS_LOCAL_WRITE)) {

and it seems really really unlikely that you would ever add any
remote permissions etc.

 - R.
