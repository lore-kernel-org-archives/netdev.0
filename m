From: Roland Dreier <rdreier-FYB4Gu1CFyUAvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH 02/25 v2] mlx4_core: add support for arbitrary bitmap sizes
Date: Wed, 03 Feb 2010 14:25:47 -0800
Message-ID: <adaaavqgdn8.fsf@roland-alpha.cisco.com>
References: <4AF39314.5020004@mellanox.co.il>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	liranl-VPRAkNaXOzVS1MOuV/RT9w@public.gmane.org, tziporet-VPRAkNaXOzVS1MOuV/RT9w@public.gmane.org
To: Yevgeny Petrilin <yevgenyp-VPRAkNaXOzVS1MOuV/RT9w@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <4AF39314.5020004-VPRAkNaXOzVS1MOuV/RT9w@public.gmane.org> (Yevgeny Petrilin's message of
	"Fri, 06 Nov 2009 05:08:04 +0200")
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

 > +int mlx4_bitmap_init_no_mask(struct mlx4_bitmap *bitmap, u32 num,
 > +			     u32 reserved_bot, u32 reserved_top)
 > +{
 > +	u32 num_rounded = roundup_pow_of_two(num);
 > +	return mlx4_bitmap_init(bitmap, num_rounded, num_rounded - 1,
 > +				reserved_bot, num_rounded - num + reserved_top);
 > +}

I think I would really prefer things if we got rid of this wrapper.  The
mlx4_bitmap stuff is really there to handle the case where we want to
have a mask and have the non-used bits cycle to avoid reusing QPN etc.
If we have a bitmap with no mask that's no a power of 2 in size, there's
really no value in the mlx4 wrapper -- we might as well just allocate a
bitmap directly.

And since this is only used in one place (for the EQ tables) I think it
makes sense to just open-code everything in the EQ code.

 - R.
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
