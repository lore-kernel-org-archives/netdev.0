From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 2/3 2.6.27] cxgb3 - Add page support to jumbo frame Rx
 queue
Date: Wed, 21 May 2008 17:20:24 -0700
Message-ID: <20080521172024.a1044aea.akpm@linux-foundation.org>
References: <20080521015737.6218.32204.stgit@speedy5>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: jeff@garzik.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, swise@opengridcomputing.com
To: Divy Le Ray <divy@chelsio.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:36575 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1760985AbYEVAVO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 May 2008 20:21:14 -0400
In-Reply-To: <20080521015737.6218.32204.stgit@speedy5>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 20 May 2008 18:57:37 -0700
Divy Le Ray <divy@chelsio.com> wrote:

> From: Divy Le Ray <divy@chelsio.com>
> 
> Add page support to Jumbo frame Rx queues.
> 
> ...
>
> @@ -460,7 +464,8 @@ nomem:				q->alloc_failed++;
>  			if (q->use_pages) {
>  				if (q->pg_chunk.page) {
>  					put_page(q->pg_chunk.page);
> -					__free_page(q->pg_chunk.page);
> +					__free_pages(q->pg_chunk.page,
> +						     q->order);
>  					q->pg_chunk.page =
>  						sd->pg_chunk.page = NULL;
>  				}

This hunk doesn't apply to 2.6.26-rc3, afacit.  The code it's patching
just isn't there.  But I think I fixed it up OK.

