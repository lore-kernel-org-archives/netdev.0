From: Christoph Hellwig <hch@lst.de>
Subject: Re: [PATCH rfc 2/6] mlx5: move affinity hints assignments to
        generic code
Date: Tue, 4 Apr 2017 08:32:13 +0200
Message-ID: <20170404063213.GB8978@lst.de>
References: <1491140492-25703-1-git-send-email-sagi@grimberg.me> <1491140492-25703-3-git-send-email-sagi@grimberg.me>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-rdma@vger.kernel.org, linux-nvme@lists.infradead.org,
        linux-block@vger.kernel.org, netdev@vger.kernel.org,
        Saeed Mahameed <saeedm@mellanox.com>,
        Or Gerlitz <ogerlitz@mellanox.com>,
        Christoph Hellwig <hch@lst.de>
To: Sagi Grimberg <sagi@grimberg.me>
Return-path: <linux-block-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1491140492-25703-3-git-send-email-sagi@grimberg.me>
Sender: linux-block-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> @@ -1375,7 +1375,8 @@ static void mlx5e_close_cq(struct mlx5e_cq *cq)
>  
>  static int mlx5e_get_cpu(struct mlx5e_priv *priv, int ix)
>  {
> -	return cpumask_first(priv->mdev->priv.irq_info[ix].mask);
> +	return cpumask_first(pci_irq_get_affinity(priv->mdev->pdev,
> +			MLX5_EQ_VEC_COMP_BASE + ix));

This looks ok for now, but if we look at the callers we'd probably
want to make direct use of pci_irq_get_node and pci_irq_get_affinity for
the uses directly in mlx5e_open_channel as well as the stored away
->cpu field.  But maybe that should be left for another patch after
this one.

> +	struct irq_affinity irqdesc = { .pre_vectors = MLX5_EQ_VEC_COMP_BASE, };

I usually move assignments inside structures onto a separate line to make
it more readable, e.g.

	struct irq_affinity irqdesc = {
		.pre_vectors = MLX5_EQ_VEC_COMP_BASE,
	};

Otherwise this looks fine:

Reviewed-by: Christoph Hellwig <hch@lst.de>
