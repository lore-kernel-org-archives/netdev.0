From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH V2] net: ethernet: mellanox: correct page conversion
Date: Mon, 18 Apr 2016 06:59:36 -0700
Message-ID: <20160418135936.GA25909@infradead.org>
References: <1460845412-13120-1-git-send-email-okaya@codeaurora.org>
 <20160418121247.GA25387@infradead.org>
 <0c6a430c5f0ec64f51d7c594ef9751dd@codeaurora.org>
 <20160418131058.GA25421@infradead.org>
 <5714E5D6.7050600@codeaurora.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Christoph Hellwig <hch@infradead.org>, linux-rdma@vger.kernel.org,
	timur@codeaurora.org, cov@codeaurora.org,
	Yishai Hadas <yishaih@mellanox.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Sinan Kaya <okaya@codeaurora.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <5714E5D6.7050600@codeaurora.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Apr 18, 2016 at 09:49:10AM -0400, Sinan Kaya wrote:
> Here is a good description of logical address vs. virtual address.
> 
> https://www.quora.com/What-is-the-Kernel-logical-and-virtual-addresses-What-is-the-difference-between-them-What-is-the-type-of-addresses-listed-in-the-System-map

That's not how we use the terms in Linux.  But it's not really the point
of my question either.

> > Is this correct?
> > 
> No, the driver is plain broken without this patch. It causes a kernel panic 
> during driver probe.
> 
> This is the definition of vmap API.
> 
> https://www.kernel.org/doc/htmldocs/kernel-api/API-vmap.html

Thanks for the pointer, but I'm actually the person who introduced vmap
to Linux a long time ago, and this is once again not my question.

> You cannot take several virtually mapped addresses returned by dma_alloc_coherent
> and try to make them virtually contiguous again. 

But now we're getting closer to the issue: the mlx4_en driver is using
vmap on buffers allocated using dma_alloc_coherent if on a 64-bit
architecture, and that's obviously broken.

Now the big quetions is: why does it do that, given that
dma_alloc_coherent can be used for high order allocations anyway (and in
fact many architectures implement is using a version of vmap).

Let's get some answers on these question from the Mellanox folks and
work from there.
