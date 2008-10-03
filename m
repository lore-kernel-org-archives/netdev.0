From: Peter Zijlstra <a.p.zijlstra@chello.nl>
Subject: Re: [PATCH 08/32] mm: slb: add knowledge of reserve pages
Date: Fri, 03 Oct 2008 11:32:38 +0200
Message-ID: <1223026358.28938.2.camel@twins>
References: <20081002130504.927878499@chello.nl>
	 <20081002131608.091390019@chello.nl>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Andrew Morton <akpm@linux-foundation.org>,
	linux-kernel@vger.kernel.org, linux-mm@kvack.org,
	netdev@vger.kernel.org, trond.myklebust@fys.uio.no,
	Daniel Lezcano <dlezcano@fr.ibm.com>,
	Pekka Enberg <penberg@cs.helsinki.fi>,
	Neil Brown <neilb@suse.de>, David Miller <davem@davemloft.net>
To: Linus Torvalds <torvalds@linux-foundation.org>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1755250AbYJCJdX@vger.kernel.org>
In-Reply-To: <20081002131608.091390019@chello.nl>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Because I'm a dork and forgot to refresh...

---
Index: linux-2.6/mm/slob.c
===================================================================
--- linux-2.6.orig/mm/slob.c
+++ linux-2.6/mm/slob.c
@@ -239,7 +239,7 @@ static int slob_last(slob_t *s)
 
 static void *slob_new_page(gfp_t gfp, int order, int node)
 {
-	void *page;
+	struct page *page;
 
 #ifdef CONFIG_NUMA
 	if (node != -1)
@@ -318,7 +318,7 @@ static void *slob_alloc(size_t size, gfp
 	slob_t *b = NULL;
 	unsigned long flags;
 
-	if (unlikely(slub_reserve)) {
+	if (unlikely(slob_reserve)) {
 		if (!(gfp_to_alloc_flags(gfp) & ALLOC_NO_WATERMARKS))
 			goto grow;
 	}
