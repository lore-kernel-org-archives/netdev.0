From: Or Gerlitz <or.gerlitz@gmail.com>
Subject: Re: [PATCH net-next] mlx4: allow order-0 memory allocations in RX path
Date: Sun, 23 Jun 2013 23:17:40 +0300
Message-ID: <CAJZOPZ+-StTDm0D-jaeWGfQqOzz5e3C92zPmQf=0_mPV3MukCQ@mail.gmail.com>
References: <1371757222-21412-1-git-send-email-amirv@mellanox.com>
	<1371757222-21412-2-git-send-email-amirv@mellanox.com>
	<1371763689.3252.419.camel@edumazet-glaptop>
	<51C6B602.20703@mellanox.com>
	<1372000676.3301.27.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Eugenia Emantayev <eugenia@mellanox.com>,
	Saeed Mahameed <saeedm@mellanox.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qc0-f180.google.com ([209.85.216.180]:55462 "EHLO
	mail-qc0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751053Ab3FWURm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 23 Jun 2013 16:17:42 -0400
Received: by mail-qc0-f180.google.com with SMTP id a1so5788556qcx.25
        for <netdev@vger.kernel.org>; Sun, 23 Jun 2013 13:17:40 -0700 (PDT)
In-Reply-To: <1372000676.3301.27.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Jun 23, 2013 at 6:17 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> Signed-off-by: Eric Dumazet <edumazet@google.com>
>
> mlx4 exclusively uses order-2 allocations in RX path, which are
> likely to fail under memory pressure.
>
> We therefore drop frames more than needed.
>
> This patch tries order-3, order-2, order-1 and finally order-0
> allocations to keep good performance, yet allow allocations if/when
> memory gets fragmented.
>
> By using larger pages, and avoiding unnecessary get_page()/put_page()
> on compound pages, this patch improves performance as well, lowering
> false sharing on struct page.

Hi Eric, thanks for the patch, both Amir and Yevgeny are OOO, so it
will take us a bit more time to conduct the review... but lets start:
could you explain a little further what do you exactly refer to by
"false sharing" in this context?

Also, I am not fully sure, but I think the current driver code doesn't
support splice and this somehow relates to how RX skbs are spread over
pages. In that repsect, I wonder if this patch goes in the direction
that would allow to support splice, or maybe takes us a bit back, as
of moving to use order-3 allocations?

You've mentioned performance improvement, could you be more specific?
what's the scheme under which you saw the improvement and what was
that improvement.

Last, as Amir wrote you, we're looking on re-using skbs on the RX
patch to avoid sever performance hits when IOMMU is enabled. The team
has not provided me yet the patch, but basically, if you look on the
ixgbe patch that was made largely for that very same purpose
(improving perf under IOMMU) f800326dca7bc158f4c886aa92f222de37993c80
"ixgbe: Replace standard receive path with a page based receive" ,
they use there order-0 or order-1 allocations, but not order-2 or
order-3, also here I have some more catch up to conduct, so we'll
see...

Or.
