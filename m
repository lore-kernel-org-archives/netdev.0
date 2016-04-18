From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH V2] net: ethernet: mellanox: correct page conversion
Date: Mon, 18 Apr 2016 07:32:55 -0700
Message-ID: <20160418143255.GA15203@infradead.org>
References: <1460845412-13120-1-git-send-email-okaya@codeaurora.org>
 <20160418065447.GA11539@x-vnc01.mtx.labs.mlnx>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Sinan Kaya <okaya@codeaurora.org>, linux-rdma@vger.kernel.org,
	timur@codeaurora.org, cov@codeaurora.org,
	Yishai Hadas <yishaih@mellanox.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Eli Cohen <eli@mellanox.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20160418065447.GA11539@x-vnc01.mtx.labs.mlnx>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Apr 18, 2016 at 09:54:47AM +0300, Eli Cohen wrote:
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

Not quite.  You still have code in mlx4_en_map_buffer that performs
this mapping later if it it wasn't mapped in mlx4_buf_alloc.

You'll need to get rid of that by ensuring max_direct for all the cases
currently using mlx4_en_map_buffer as well.
