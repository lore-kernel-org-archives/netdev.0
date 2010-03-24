From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [PATCH] skbuff: remove unused dma_head & dma_maps fields
Date: Tue, 23 Mar 2010 23:40:50 -0700
Message-ID: <20100324064049.32298.87859.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	Alexander Duyck <alexander.h.duyck@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta11.westchester.pa.mail.comcast.net ([76.96.59.211]:48877
	"EHLO QMTA11.westchester.pa.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751891Ab0CXGlJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Mar 2010 02:41:09 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@intel.com>

The dma map fields in the skb_shared_info structure no longer has any users
and can be dropped since it is making the skb_shared_info unecessarily larger.

Running slabtop show that we were using 4K slabs for the skb->head on x86_64 w/
an allocation size of 1522.  It turns out that the dma_head and dma_maps array
made skb_shared large enough that we had crossed over the 2k boundary with
standard frames and as such we were using 4k blocks of memory for all skbs.

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 include/linux/skbuff.h |    6 ------
 1 files changed, 0 insertions(+), 6 deletions(-)

diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index 03f816a..124f90c 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -190,9 +190,6 @@ struct skb_shared_info {
 	atomic_t	dataref;
 	unsigned short	nr_frags;
 	unsigned short	gso_size;
-#ifdef CONFIG_HAS_DMA
-	dma_addr_t	dma_head;
-#endif
 	/* Warning: this field is not always filled in (UFO)! */
 	unsigned short	gso_segs;
 	unsigned short  gso_type;
@@ -201,9 +198,6 @@ struct skb_shared_info {
 	struct sk_buff	*frag_list;
 	struct skb_shared_hwtstamps hwtstamps;
 	skb_frag_t	frags[MAX_SKB_FRAGS];
-#ifdef CONFIG_HAS_DMA
-	dma_addr_t	dma_maps[MAX_SKB_FRAGS];
-#endif
 	/* Intermediate layers must ensure that destructor_arg
 	 * remains valid until skb destructor */
 	void *		destructor_arg;

