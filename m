From: David Howells <dhowells@redhat.com>
Subject: [PATCH] NOMMU: Provide page_mkclean() for NOMMU
Date: Tue, 05 Sep 2006 16:29:33 +0100
Message-ID: <6081.1157470173@warthog.cambridge.redhat.com>
References: <20060905132530.GD9173@stusta.de>  <20060901015818.42767813.akpm@osdl.org>
Cc: Andrew Morton <akpm@osdl.org>,
	Arjan van de Ven <arjan@linux.intel.com>,
	linux-kernel@vger.kernel.org, Ingo Molnar <mingo@elte.hu>,
	Jeff Garzik <jeff@garzik.org>, netdev@vger.kernel.org,
	David Howells <dhowells@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:48871 "EHLO mx1.redhat.com")
	by vger.kernel.org with ESMTP id S965128AbWIEPbm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Sep 2006 11:31:42 -0400
In-Reply-To: <20060905132530.GD9173@stusta.de> 
To: Adrian Bunk <bunk@stusta.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Provide a page_mkclean() implementation for NOMMU.  This doesn't do anything
except return successfully as there are no PTEs for it to play with.

This is only relevant to the -mm kernels.

Signed-Off-By: David Howells <dhowells@redhat.com>
---
warthog>diffstat -p1 nommu-page_mkclean-2618rc5mm1.diff 
 include/linux/rmap.h |    6 ++++++
 1 file changed, 6 insertions(+)

diff -urp ../kernels/linux-2.6.18-rc5-mm1/include/linux/rmap.h linux-2.6.18-rc5-mm1-frv/include/linux/rmap.h
--- ../kernels/linux-2.6.18-rc5-mm1/include/linux/rmap.h	2006-09-04 18:03:32.000000000 +0100
+++ linux-2.6.18-rc5-mm1-frv/include/linux/rmap.h	2006-09-05 15:34:35.000000000 +0100
@@ -120,6 +120,12 @@ int page_mkclean(struct page *);
 #define page_referenced(page,l) TestClearPageReferenced(page)
 #define try_to_unmap(page, refs) SWAP_FAIL
 
+static inline int page_mkclean(struct page *page)
+{
+	return 0;
+}
+
+
 #endif	/* CONFIG_MMU */
 
 /*
