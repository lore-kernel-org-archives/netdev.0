From: Jason Gunthorpe <jgunthorpe-ePGOBjL8dl3ta4EC/59zMFaTQe2KTcn/@public.gmane.org>
Subject: Re: [PATCH for-next V1 1/2] net/mlx5: Fix mlx5 ifc cmd_hca_cap bad
 offsets
Date: Wed, 13 Apr 2016 11:48:20 -0600
Message-ID: <20160413174820.GC28411@obsidianresearch.com>
References: <1460563864-22931-1-git-send-email-saeedm@mellanox.com>
 <1460563864-22931-2-git-send-email-saeedm@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	Doug Ledford <dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Linus Torvalds <torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>,
	Or Gerlitz <ogerlitz-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	Matan Barak <matanb-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	Leon Romanovsky <leonro-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	Tal Alon <talal-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	Tariq Toukan <tariqt-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
To: Saeed Mahameed <saeedm-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1460563864-22931-2-git-send-email-saeedm-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Wed, Apr 13, 2016 at 07:11:03PM +0300, Saeed Mahameed wrote:

> Fixes: b0844444590e ("net/mlx5_core: Introduce access function to read internal timer ")
> Fixes: b4ff3a36d3e4 ("net/mlx5: Use offset based reserved field names in the IFC header file")

Are you sure those are right? b0844444590e doesn't have the
reserved_at names.

>  	u8         ets[0x1];
>  	u8         nic_flow_table[0x1];
>  	u8         eswitch_flow_table[0x1];
> -	u8	   early_vf_enable;
> -	u8         reserved_at_1a8[0x2];
> +	u8	   early_vf_enable[0x1];
> +	u8         reserved_at_1a9[0x2];

You know, the reserved_XXX just need to have unique unchanging
numbers, it doesn't matter what the numbers are - but you have to stop
changing them :( That is the key to avoiding conflicts when
backporting/merging/etc.

I guess the big rename has already landed, but simply stopping the
practice of renumbing the reserved fields would have been enough.

Jason
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
