From: Dan Williams <dan.j.williams@intel.com>
Subject: [PATCH resend] net_dma: remove duplicate assignment in
	dma_skb_copy_datagram_iovec
Date: Thu, 22 May 2008 13:56:11 -0700
Message-ID: <1211489771.16376.24.camel@dwillia2-linux.ch.intel.com>
References: <7F38996F7185A24AB9071ED4950AD8C1013A15FE@swsmsx413.ger.corp.intel.com>
	 <1204305793.31065.4.camel@dwillia2-linux.ch.intel.com>
	 <48351A7B.90309@inria.fr>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "Sosnowski, Maciej" <maciej.sosnowski@intel.com>,
	Brice Goglin <Brice.Goglin@inria.fr>, netdev@vger.kernel.org,
	"Nelson, Shannon" <shannon.nelson@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([143.182.124.37]:4289 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756598AbYEVU4M (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 22 May 2008 16:56:12 -0400
In-Reply-To: <48351A7B.90309@inria.fr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Brice Goglin <Brice.Goglin@inria.fr>
Subject: net_dma: remove duplicate assignment in dma_skb_copy_datagram_iovec

No need to compute copy twice in the frags loop in
dma_skb_copy_datagram_iovec().

Signed-off-by: Brice Goglin <Brice.Goglin@inria.fr>
Acked-by: Shannon Nelson <shannon.nelson@intel.com>
Signed-off-by: Maciej Sosnowski <maciej.sosnowski@intel.com>
Signed-off-by: Dan Williams <dan.j.williams@intel.com>
---
On Thu, 2008-05-22 at 00:02 -0700, Brice Goglin wrote:
> I don't see this patch applied anywhere, what happened to it?
>
> Brice

Hi Dave,

Looks like this patch fell by the wayside, here is a resend.

Thanks,
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
 


