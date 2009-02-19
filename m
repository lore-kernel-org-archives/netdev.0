From: Ingo Molnar <mingo@elte.hu>
Subject: Re: [PATCH 11/12]Remove defines of DMA_XXBIT_MASK micro
Date: Thu, 19 Feb 2009 09:14:03 +0100
Message-ID: <20090219081403.GA5400@elte.hu>
References: <499CFDC8.1070600@cn.fujitsu.com> <499D0221.9090407@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andrew Morton <akpm@linux-foundation.org>,
	"David S. Miller" <davem@davemloft.net>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	Borislav Petkov <petkovbb@googlemail.com>
To: Yang Hongyang <yanghy@cn.fujitsu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx3.mail.elte.hu ([157.181.1.138]:38876 "EHLO mx3.mail.elte.hu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751911AbZBSIOd (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 19 Feb 2009 03:14:33 -0500
Content-Disposition: inline
In-Reply-To: <499D0221.9090407@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


* Yang Hongyang <yanghy@cn.fujitsu.com> wrote:

> Remove defines of DMA_XXBIT_MASK micro
> 
> Signed-off-by: Yang Hongyang<yanghy@cn.fujitsu.com>
> 
> ---
>  include/linux/dma-mapping.h |   20 +-------------------
>  1 files changed, 1 insertions(+), 19 deletions(-)
> 
> diff --git a/include/linux/dma-mapping.h b/include/linux/dma-mapping.h
> index f238c7e..70f9c63 100644
> --- a/include/linux/dma-mapping.h
> +++ b/include/linux/dma-mapping.h
> @@ -13,27 +13,9 @@ enum dma_data_direction {
>  	DMA_NONE = 3,
>  };
>  
> +/*use DMA_BIT_MASK(n) within your driver instead of DMA_xxBIT_MASK*/
>  #define DMA_BIT_MASK(n)	(((n) == 64) ? ~0ULL : ((1ULL<<(n))-1))
>  
> -/*
> - * NOTE: do not use the below macros in new code and do not add new definitions
> - * here.
> - *
> - * Instead, just open-code DMA_BIT_MASK(n) within your driver
> - */
> -#define DMA_64BIT_MASK	DMA_BIT_MASK(64)
> -#define DMA_48BIT_MASK	DMA_BIT_MASK(48)
> -#define DMA_47BIT_MASK	DMA_BIT_MASK(47)
> -#define DMA_40BIT_MASK	DMA_BIT_MASK(40)
> -#define DMA_39BIT_MASK	DMA_BIT_MASK(39)
> -#define DMA_35BIT_MASK	DMA_BIT_MASK(35)
> -#define DMA_32BIT_MASK	DMA_BIT_MASK(32)
> -#define DMA_31BIT_MASK	DMA_BIT_MASK(31)
> -#define DMA_30BIT_MASK	DMA_BIT_MASK(30)
> -#define DMA_29BIT_MASK	DMA_BIT_MASK(29)
> -#define DMA_28BIT_MASK	DMA_BIT_MASK(28)
> -#define DMA_24BIT_MASK	DMA_BIT_MASK(24)

Looks good beyond the s/micro/macro typo fix, but i'd suggest to 
keep these old defines for one more kernel cycle, then do a 
final removal of all remaining uses, in a single patch.

That way we'll save ourselves from quite a bit of unnecessary 
build breakages (as your patchset shows there's still a lot of 
users of the old macros), as these definitions get moved around, 
reintroduced, etc.

Conflict resolution becomes easier as well - if such a patch 
conflicts with some ongoing work then we can by avoid the 
conflict by just dropping that hunk and delaying that particular 
conversion to the 'final' stage.

	Ingo
