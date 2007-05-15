From: Christoph Lameter <clameter@sgi.com>
Subject: Re: select(0, ..) is valid ?
Date: Tue, 15 May 2007 11:36:43 -0700 (PDT)
Message-ID: <Pine.LNX.4.64.0705151136150.31972@schroedinger.engr.sgi.com>
References: <1179250159.2836.117.camel@dyn9047017100.beaverton.ibm.com>
 <20070515104453.f901e91f.akpm@linux-foundation.org>
 <Pine.LNX.4.64.0705151109021.31972@schroedinger.engr.sgi.com>
 <20070515113033.75d7bff6.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Badari Pulavarty <pbadari@us.ibm.com>, netdev@vger.kernel.org,
	lkml <linux-kernel@vger.kernel.org>
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from netops-testserver-4-out.sgi.com ([192.48.171.29]:50918 "EHLO
	relay.sgi.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1756615AbXEOSgo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 May 2007 14:36:44 -0400
In-Reply-To: <20070515113033.75d7bff6.akpm@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 15 May 2007, Andrew Morton wrote:

> Perhaps putting a size=0 detector into slab also would speed this
> process up.

Signed-off-by: Christoph Lameter <clameter@sgi.com>

Index: linux-2.6/mm/slab.c
===================================================================
--- linux-2.6.orig/mm/slab.c	2007-05-15 11:32:25.000000000 -0700
+++ linux-2.6/mm/slab.c	2007-05-15 11:35:55.000000000 -0700
@@ -792,6 +792,7 @@ static inline struct kmem_cache *__find_
 	 */
 	BUG_ON(malloc_sizes[INDEX_AC].cs_cachep == NULL);
 #endif
+	WARN_ON_ONCE(size == 0);
 	while (size > csizep->cs_size)
 		csizep++;
 
