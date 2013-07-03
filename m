From: Joe Perches <joe-6d6DIl74uiNBDgjK7y7TUQ@public.gmane.org>
Subject: Re: [PATCH V2 5/9] IB/mlx5: Mellanox Connect-IB, IB driver part 1/5
Date: Wed, 03 Jul 2013 13:59:28 -0700
Message-ID: <1372885168.1886.17.camel@joe-AO722>
References: <1372871592-32033-1-git-send-email-ogerlitz@mellanox.com>
	 <1372871592-32033-6-git-send-email-ogerlitz@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: roland-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org, linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org,
	jackm-LDSdmyG8hGV8YrgS2mwiifqBs+8SCbDb@public.gmane.org, eli-LDSdmyG8hGV8YrgS2mwiifqBs+8SCbDb@public.gmane.org,
	moshel-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org, Eli Cohen <eli-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
To: Or Gerlitz <ogerlitz-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1372871592-32033-6-git-send-email-ogerlitz-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Wed, 2013-07-03 at 20:13 +0300, Or Gerlitz wrote:
> From: Eli Cohen <eli-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>

more trivia:

> diff --git a/drivers/infiniband/hw/mlx5/ah.c b/drivers/infiniband/hw/mlx5/ah.c
[]
> +struct ib_ah *create_ib_ah(struct ib_ah_attr *ah_attr,
> +			   struct mlx5_ib_ah *ah)
> +{
> +	u32 sgi;

sgi is used once here and looks more confusing than helpful

> +
> +	if (ah_attr->ah_flags & IB_AH_GRH) {
> +		sgi = ah_attr->grh.sgid_index << 20;
> +
> +		memcpy(ah->av.rgid, &ah_attr->grh.dgid, 16);
> +		ah->av.grh_gid_fl = cpu_to_be32(ah_attr->grh.flow_label |
> +						(1 << 30) | sgi);
> +		ah->av.hop_limit = ah_attr->grh.hop_limit;
> +		ah->av.tclass = ah_attr->grh.traffic_class;
> +	}
> +
> +	ah->av.rlid = cpu_to_be16(ah_attr->dlid);
> +	ah->av.fl_mlid = ah_attr->src_path_bits & 0x7f;
> +	ah->av.stat_rate_sl = (ah_attr->static_rate << 4) | (ah_attr->sl & 0xf);
> +
> +	return &ah->ibah;
> +}

[]

> +static void *get_sw_cqe(struct mlx5_ib_cq *cq, int n)
> +{
> +	void *cqe = get_cqe(cq, n & cq->ibcq.cqe);
> +	struct mlx5_cqe64 *cqe64;
> +
> +	cqe64 = (cq->mcq.cqe_sz == 64) ? cqe : cqe + 64;
> +	return ((cqe64->op_own & MLX5_CQE_OWNER_MASK) ^
> +		!!(n & (cq->ibcq.cqe + 1))) ? NULL : cqe;

I think "foo ^ !!bar" is excessively tricky.

> +static enum ib_wc_opcode get_umr_comp(struct mlx5_ib_wq *wq, int idx)
> +{

> +		pr_warn("unkonwn completion status\n");

unknown tyop

[]

> +static int create_cq_user(struct mlx5_ib_dev *dev, struct ib_udata *udata,
> +			  struct ib_ucontext *context, struct mlx5_ib_cq *cq,
> +			  int entries, struct mlx5_create_cq_mbox_in **cqb,
> +			  int *cqe_size, int *index, int *inlen)
[]
> +	*inlen = sizeof **cqb + sizeof *(*cqb)->pas * ncont;

sizeof always uses parentheses

> +	*cqb = vzalloc(*inlen);

Perhaps you may be using vzalloc too often.

Maybe you should have a helper allocating either
from kmalloc or vmalloc as necessary based on size.


--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
