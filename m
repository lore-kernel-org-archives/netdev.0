From: Jarek Poplawski <jarkao2@o2.pl>
Subject: Re: [PATCH] Re: kernel BUG in eth_alloc_tx_desc_index at drivers/net/mv643xx_eth.c:1069!
Date: Tue, 23 Jan 2007 09:17:09 +0100
Message-ID: <20070123081709.GA1925@ff.dom.local>
References: <20070109130220.GA4060@ff.dom.local> <7d01f9f00701090944o62f39fb4yfaa5449c2d2d010d@mail.gmail.com> <20070109200541.GA27089@xyzzy.farnsworth.org> <7d01f9f00701091305n3a82713fla442a70a6098dbf@mail.gmail.com> <7d01f9f00701100912kc6fb635wd863d9563b0eb328@mail.gmail.com> <20070111104220.GA3171@ff.dom.local> <7d01f9f00701210418q6f506d20tdc9ce10b501370d7@mail.gmail.com> <7d01f9f00701210502m2bb96bd8i5071a76b6a8c3ea0@mail.gmail.com> <20070122100236.GC2079@ff.dom.local> <20070122170615.GA15293@xyzzy.farnsworth.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Thibaut VARENE <T-Bone@parisc-linux.org>, netdev@vger.kernel.org,
	mlachwani@mvista.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from poczta.o2.pl ([193.17.41.142]:38628 "EHLO poczta.o2.pl"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S932899AbXAWIOq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 23 Jan 2007 03:14:46 -0500
To: Dale Farnsworth <dale@farnsworth.org>
Content-Disposition: inline
In-Reply-To: <20070122170615.GA15293@xyzzy.farnsworth.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Jan 22, 2007 at 10:06:16AM -0700, Dale Farnsworth wrote:
> Jarek and Thibaut,
> 
> Thank you both very much for your work finding and fixing this bug.
> Jarek, can you verify that the following patch fixes the problem you
> were seeing?
> 
> -Dale

Sorry, only Thibaut can verify this. I don't have
such card.

I can only confirm that your patch fixes unproper
locking of mp->tx_desc_count in the while condition.
But I'm not sure your way is optimal now because
mp->tx_desc_count is checked 2 times per every loop.
I think it is right only if you know the function
mv643xx_eth_free_tx_descs is called mostly while 
mp->tx_desc_count == 0 or 1.

> ----- Patch follows -----
> 
> From: Dale Farnsworth <dale@farnsworth.org>
> 
> mv643xx_eth: Fix race condition in mv643xx_eth_free_tx_descs
> 
> The bug was found and isolated by Thibaut VARENE <T-Bone@parisc-linux.org>
> and Jarek Poplawski <jarkao2@o2.pl>.  This patch is a modification of their
> fixes.  We acquire and release the lock for each descriptor that is freed
> to minimize the time the lock is held.
> 
> ---

From: Dale Farnsworth <dale@farnsworth.org>
 
mv643xx_eth: Fix race condition in mv643xx_eth_free_tx_descs
 
The bug was found and isolated by Thibaut VARENE <T-Bone@parisc-linux.org>
and Jarek Poplawski <jarkao2@o2.pl> noticed a locking problem.  This patch
is a modification of their fixes.  We acquire and release the lock for each
descriptor that is freed to minimize the time the lock is held.
 
---

I did small adjustment of my role here.

Regards,
Jarek P.
