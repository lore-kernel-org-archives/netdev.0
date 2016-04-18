From: Sinan Kaya <okaya@codeaurora.org>
Subject: Re: [PATCH V2] net: ethernet: mellanox: correct page conversion
Date: Mon, 18 Apr 2016 09:53:30 -0400
Message-ID: <5714E6DA.4080008@codeaurora.org>
References: <1460845412-13120-1-git-send-email-okaya@codeaurora.org>
 <20160418065447.GA11539@x-vnc01.mtx.labs.mlnx>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: linux-rdma@vger.kernel.org, timur@codeaurora.org,
	cov@codeaurora.org, Yishai Hadas <yishaih@mellanox.com>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Eli Cohen <eli@mellanox.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160418065447.GA11539@x-vnc01.mtx.labs.mlnx>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 4/18/2016 2:54 AM, Eli Cohen wrote:
> Sinan,
> 
> if we get rid of the part this code:
> 
>                 if (BITS_PER_LONG == 64) {
>                         struct page **pages;
>                         pages = kmalloc(sizeof *pages * buf->nbufs, gfp);
>                         if (!pages)
>                                 goto err_free;
>                         ...
>                         ...
>                         if (!buf->direct.buf)
>                                 goto err_free;
>                 }
> 
> Does that solve the arm issue?

I will test. As far as I know, there is one more place these DMA addresses
are called with vmap. This is in mlx4_en_map_buffer.

I was trying to rearrange the allocation so that vmap actually works.

What do you think about mlx4_en_map_buffer?


-- 
Sinan Kaya
Qualcomm Technologies, Inc. on behalf of Qualcomm Innovation Center, Inc.
Qualcomm Innovation Center, Inc. is a member of Code Aurora Forum, a Linux Foundation Collaborative Project
