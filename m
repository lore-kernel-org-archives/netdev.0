From: Dan Williams <dan.j.williams@intel.com>
Subject: Re: FW: [PATCH][I/OAT]: Remove duplicate assignation in
	dma_skb_copy_datagram_iovec
Date: Fri, 29 Feb 2008 10:23:13 -0700
Message-ID: <1204305793.31065.4.camel@dwillia2-linux.ch.intel.com>
References: <7F38996F7185A24AB9071ED4950AD8C1013A15FE@swsmsx413.ger.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org, Brice.Goglin@inria.fr,
	"Nelson, Shannon" <shannon.nelson@intel.com>
To: "Sosnowski, Maciej" <maciej.sosnowski@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:43188 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750803AbYB2R2f (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 29 Feb 2008 12:28:35 -0500
In-Reply-To: <7F38996F7185A24AB9071ED4950AD8C1013A15FE@swsmsx413.ger.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Subject: net_dma: Remove duplicate assignment in dma_skb_copy_datagram_iovec

From: Brice Goglin <Brice.Goglin@inria.fr>

No need to compute copy twice in the frags loop in
dma_skb_copy_datagram_iovec().

Signed-off-by: Brice Goglin <Brice.Goglin@inria.fr>
Acked-by: Shannon Nelson <shannon.nelson@intel.com>
Signed-off-by: Maciej Sosnowski <maciej.sosnowski@intel.com>
Signed-off-by: Dan Williams <dan.j.williams@intel.com>
---
Hi Maciej,

Please be careful about maintaining attribution of the patch.

Regards,
Dan

 net/core/user_dma.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)


diff --git a/net/core/user_dma.c b/net/core/user_dma.c
index 0ad1cd5..c77aff9 100644
--- a/net/core/user_dma.c
+++ b/net/core/user_dma.c
@@ -75,7 +75,7 @@ int dma_skb_copy_datagram_iovec(struct dma_chan *chan,
 
 		end = start + skb_shinfo(skb)->frags[i].size;
 		copy = end - offset;
-		if ((copy = end - offset) > 0) {
+		if (copy > 0) {
 			skb_frag_t *frag = &skb_shinfo(skb)->frags[i];
 			struct page *page = frag->page;
 


