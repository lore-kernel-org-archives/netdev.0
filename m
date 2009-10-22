From: Mel Gorman <mel-wPRd99KPJ+uzQB+pC5nmwQ@public.gmane.org>
Subject: [PATCH 2/5] page allocator: Do not allow interrupts to use ALLOC_HARDER
Date: Thu, 22 Oct 2009 15:22:33 +0100
Message-ID: <1256221356-26049-3-git-send-email-mel@csn.ul.ie>
References: <1256221356-26049-1-git-send-email-mel@csn.ul.ie>
Cc: "Rafael J. Wysocki" <rjw-KKrjLPT3xs0@public.gmane.org>,
	David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	Reinette Chatre <reinette.chatre-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
	Kalle Valo <kalle.valo-X3B1VOXEql0@public.gmane.org>,
	David Rientjes <rientjes-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>,
	KOSAKI Motohiro <kosaki.motohiro-+CUm20s59erQFUHtdCDX3A@public.gmane.org>,
	Mohamed Abbas <mohamed.abbas-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
	Jens Axboe <jens.axboe-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>,
	"John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>,
	Pekka Enberg <penberg-bbCR+/B0CizivPeTLB3BmA@public.gmane.org>,
	Bartlomiej Zolnierkiewicz <bzolnier-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Greg Kroah-Hartman <gregkh-l3A5Bk7waGM@public.gmane.org>,
	Stephan von Krawczynski <skraw-DcQCyzbjH0jQT0dZR+AlfA@public.gmane.org>,
	Kernel Testers List <kernel-testers-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	"linux-mm-Bw31MaZKKs3YtjvyW6yDsg@public.gmane.org\"" <linux-mm-Bw31MaZKKs3YtjvyW6yDsg@public.gmane.org>,
	Mel Gorman <mel-wPRd99KPJ+uzQB+pC5nmwQ@public.gmane.org>
To: Frans Pop <elendil-EIBgga6/0yRmR6Xm/wNWPw@public.gmane.org>, Jiri Kosina <jkosina-AlSwsSmVLrQ@public.gmane.org>,
	Sven Geggus <lists-+AJD3D7QEjjt/htJsj1pd9AswbaBtrod@public.gmane.org>,
	Karol Lewandowski <karol.k.lewandowski-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Tobias Oetiker <tobi-7K0TWYW2a3pyDzI6CaY1VQ@public.gmane.org>
Return-path: <kernel-testers-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1256221356-26049-1-git-send-email-mel-wPRd99KPJ+uzQB+pC5nmwQ@public.gmane.org>
Sender: kernel-testers-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Commit 341ce06f69abfafa31b9468410a13dbd60e2b237 altered watermark logic
slightly by allowing rt_tasks that are handling an interrupt to set
ALLOC_HARDER. This patch brings the watermark logic more in line with
2.6.30.

[rientjes-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org: Spotted the problem]
Signed-off-by: Mel Gorman <mel-wPRd99KPJ+uzQB+pC5nmwQ@public.gmane.org>
Reviewed-by: Pekka Enberg <penberg-bbCR+/B0CizivPeTLB3BmA@public.gmane.org>
---
 mm/page_alloc.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index dfa4362..7f2aa3e 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -1769,7 +1769,7 @@ gfp_to_alloc_flags(gfp_t gfp_mask)
 		 * See also cpuset_zone_allowed() comment in kernel/cpuset.c.
 		 */
 		alloc_flags &= ~ALLOC_CPUSET;
-	} else if (unlikely(rt_task(p)))
+	} else if (unlikely(rt_task(p)) && !in_interrupt())
 		alloc_flags |= ALLOC_HARDER;
 
 	if (likely(!(gfp_mask & __GFP_NOMEMALLOC))) {
-- 
1.6.3.3
