From: Honggang LI <honli-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: Re: [linux-next PATCH] mlx5: wrong page mask if
  CONFIG_ARCH_DMA_ADDR_T_64BIT enabled for 32Bit architectures
Date: Mon, 13 Apr 2015 17:19:38 +0800
Message-ID: <20150413091937.GA23372@honli.nay.redhat.com>
References: <1428836751-23037-1-git-send-email-honli@redhat.com>
 <DB4PR05MB4487E0A2EDB25BF090A9742C5F80@DB4PR05MB448.eurprd05.prod.outlook.com>
 <20150413003333.GA17193@honli.nay.redhat.com>
 <DB4PR05MB448D41F0471F690E688F6BCC5E70@DB4PR05MB448.eurprd05.prod.outlook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Eli Cohen <eli-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <DB4PR05MB448D41F0471F690E688F6BCC5E70-xsq7jzH2t6kaHWsdJSteB2u6+pknBqLbXA4E9RH9d+qIuWR1G4zioA@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Mon, Apr 13, 2015 at 06:47:11AM +0000, Eli Cohen wrote:
>  On Mon, Apr 13, 2015 at 08:33:33AM +0800, Honggang LI wrote:
> > 
> > Yes, replaced all of the PAGE_MASK in the file. Please see attched new
> > patch.
> > 
> 
> I think you need to send the new patch inline in your email.
> 

I will resent the patch.

> > > 
> > > @@ -241,7 +243,7 @@ static void free_4k(struct mlx5_core_dev *dev, u64 addr)  static int alloc_system_page(struct mlx5_core_dev *dev, u16 func_id)  {
> > >     struct page *page;
> > > -   u64 addr;
> > > +   u64 addr = 0; [Eli] Why is this required?
> > 
> > For 32bit architectures, if CONFIG_ARCH_DMA_ADDR_T_64BIT disabled and
> > physical memory is less than 4GB, dma_map_page will return an u32 integer 
> > less than 0xffff_ffff. And if addr had been initialized with random
> > rubbish in the stack of alloc_system_page, the high four bytes is
> > unpredictable. The new mask, MLX5_NUM_4K_IN_PAGE, will reserve the high
> > four bytes. So, free_4k/find_fw_page will randomly failed.
> > 
> 
> Sorry, I still don't understand the issue here. MLX5_NUM_4K_IN_PAGE is
> not a mask and will always get the correct value which is fairly
> small.

Sorry. It was a typo. It should be MLX5_U64_4K_PAGE_MASK.


--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
