From: Jesper Juhl <jj@chaosbits.net>
Subject: Re: [PATCH v2] Broadcom CNIC core network driver: fix mem leak on
 allocation failures in cnic_alloc_uio_rings()
Date: Sun, 2 Jan 2011 19:54:31 +0100 (CET)
Message-ID: <alpine.LNX.2.00.1101021952400.11481@swampdragon.chaosbits.net>
References: <alpine.LNX.2.00.1012262124320.20797@swampdragon.chaosbits.net> <1293396850.7726.14.camel@Joe-Laptop> <alpine.LNX.2.00.1012262154420.20797@swampdragon.chaosbits.net> <20101231.112025.245393392.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: joe@perches.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, zongxi@broadcom.com,
	mchan@broadcom.com
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20101231.112025.245393392.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 31 Dec 2010, David Miller wrote:

> From: Jesper Juhl <jj@chaosbits.net>
> Date: Sun, 26 Dec 2010 21:57:39 +0100 (CET)
> 
> > We are leaking memory in drivers/net/cnic.c::cnic_alloc_uio_rings() if 
> > either of the calls to dma_alloc_coherent() fail. This patch fixes it by 
> > freeing both the memory allocated with kzalloc() and memory allocated with 
> > previous calls to dma_alloc_coherent() when there's a failure.
> > 
> > Thanks to  Joe Perches <joe@perches.com>  for suggesting a better 
> > implementation than my initial version.
> > 
> > 
> > Signed-off-by: Jesper Juhl <jj@chaosbits.net>
> 
>  ...
> > + err_dma:
> > +	dma_free_coherent(&udev->pdev->dev, udev->l2_ring_size,
> > +       			  udev->l2_ring, udev->l2_ring_map);
> 
> Space before tab in indentation, improperly positioned third argument
> indentation.
> 
Whoops.

> I fixed all of this up, but please do not skimp on making sure these
> details are taken care of when updating your patch in response to feedback.
> 
I usually try to take care that such things are in order. I often even 
point these details out to other people. It slipped past me this time. 
That was a mistake. Sorry.


-- 
Jesper Juhl <jj@chaosbits.net>            http://www.chaosbits.net/
Don't top-post http://www.catb.org/~esr/jargon/html/T/top-post.html
Plain text mails only, please.
