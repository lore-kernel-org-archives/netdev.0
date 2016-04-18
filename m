From: Eli Cohen <eli@mellanox.com>
Subject: Re: [PATCH V2] net: ethernet: mellanox: correct page conversion
Date: Mon, 18 Apr 2016 17:05:20 +0300
Message-ID: <20160418140520.GC11539@x-vnc01.mtx.labs.mlnx>
References: <1460845412-13120-1-git-send-email-okaya@codeaurora.org>
 <20160418065447.GA11539@x-vnc01.mtx.labs.mlnx>
 <5714E6DA.4080008@codeaurora.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-rdma@vger.kernel.org, timur@codeaurora.org,
	cov@codeaurora.org, Yishai Hadas <yishaih@mellanox.com>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Sinan Kaya <okaya@codeaurora.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <5714E6DA.4080008@codeaurora.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Sure, this is not the complete patch. As far as I know the problem
you're facing with arm is that virt_to_page() does not provide the
correct page descriptor so my suggestion will eliminate the need for
it.

On Mon, Apr 18, 2016 at 09:53:30AM -0400, Sinan Kaya wrote:
> On 4/18/2016 2:54 AM, Eli Cohen wrote:
> > Sinan,
> > 
> > if we get rid of the part this code:
> > 
> >                 if (BITS_PER_LONG == 64) {
> >                         struct page **pages;
> >                         pages = kmalloc(sizeof *pages * buf->nbufs, gfp);
> >                         if (!pages)
> >                                 goto err_free;
> >                         ...
> >                         ...
> >                         if (!buf->direct.buf)
> >                                 goto err_free;
> >                 }
> > 
> > Does that solve the arm issue?
> 
> I will test. As far as I know, there is one more place these DMA addresses
> are called with vmap. This is in mlx4_en_map_buffer.
> 
> I was trying to rearrange the allocation so that vmap actually works.
> 
> What do you think about mlx4_en_map_buffer?
> 
> 
> -- 
> Sinan Kaya
> Qualcomm Technologies, Inc. on behalf of Qualcomm Innovation Center, Inc.
> Qualcomm Innovation Center, Inc. is a member of Code Aurora Forum, a Linux Foundation Collaborative Project
> --
> To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
