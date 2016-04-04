From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v3 1/2] RDS: fix "Kernel unaligned access" on sparc64
Date: Mon, 04 Apr 2016 15:57:46 -0400 (EDT)
Message-ID: <20160404.155746.167310851507943497.davem@davemloft.net>
References: <1459686244-14939-1-git-send-email-shamir.rabinovitch@oracle.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: rds-devel@oss.oracle.com, netdev@vger.kernel.org
To: shamir.rabinovitch@oracle.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:49919 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755116AbcDDT5y (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Apr 2016 15:57:54 -0400
In-Reply-To: <1459686244-14939-1-git-send-email-shamir.rabinovitch@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Shamir Rabinovitch <shamir.rabinovitch@oracle.com>
Date: Sun,  3 Apr 2016 08:24:03 -0400

> @@ -135,8 +135,9 @@ int rds_page_remainder_alloc(struct scatterlist *scat, unsigned long bytes,
>  			if (rem->r_offset != 0)
>  				rds_stats_inc(s_page_remainder_hit);
>  
> -			rem->r_offset += bytes;
> -			if (rem->r_offset == PAGE_SIZE) {
> +			/* fix 'Kernel unaligned access' on sparc64 */
> +			rem->r_offset += ALIGN(bytes, 8);
> +			if (rem->r_offset >= PAGE_SIZE) {

It is inappropriate to mark things with a comment like this in code
that has nothing at all to do what a specific architecture.

64-bit alignment, and this requirement, is also not sparc64 specific.
Other architectures have the same issue.

Next, comments should aide in the understanding of what the code is
trying to accomplish, when necessary.  So, something more appropriate
would be:

	/* Objects in this memory can countain 64-bit integers, align
	 * in order to accomodate that.
	 */

But it's very close to obvious here what the code is doing, and why
it might be doing so.

So I'd so no comment at all works best here.

I'm sorry, but it's a real pet peeve of mine when people mention
totally irrelevant crap in code comments.  What the heck does sparc64
have to do with aligning memory properly for the data types you will
be storing in that memory?!?!
