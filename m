From: "Sosnowski, Maciej" <maciej.sosnowski@intel.com>
Subject: FW: [PATCH][I/OAT]: Remove duplicate assignation in dma_skb_copy_datagram_iovec
Date: Fri, 29 Feb 2008 14:30:00 -0000
Message-ID: <7F38996F7185A24AB9071ED4950AD8C1013A15FE@swsmsx413.ger.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: <netdev@vger.kernel.org>, <Brice.Goglin@inria.fr>,
	"Nelson, Shannon" <shannon.nelson@intel.com>,
	"Williams, Dan J" <dan.j.williams@intel.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:46226 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757695AbYB2OhE convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 Feb 2008 09:37:04 -0500
Content-class: urn:content-classes:message
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dave,

This patch just removes redundant copy calculation. Please include it in
the tree.

Regards,
Maciej

[I/OAT]: Remove duplicate assignation in dma_skb_copy_datagram_iovec

No need to compute copy twice in the frags loop in
dma_skb_copy_datagram_iovec().

Signed-off-by: Brice Goglin <Brice.Goglin@inria.fr>
Signed-off-by: Maciej Sosnowski <maciej.sosnowski@intel.com>
---
user_dma.c |    2 +-
1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/core/user_dma.c b/net/core/user_dma.c
index 0ad1cd5..c77aff9 100644
--- a/net/core/user_dma.c
+++ b/net/core/user_dma.c
@@ -75,7 +75,7 @@ int dma_skb_copy_datagram_iovec(struct dma_chan *chan,

               end = start + skb_shinfo(skb)->frags[i].size;
               copy = end - offset;
-               if ((copy = end - offset) > 0) {
+               if (copy > 0) {
                       skb_frag_t *frag = &skb_shinfo(skb)->frags[i];
                       struct page *page = frag->page;

Acked-by: Shannon Nelson <shannon.nelson@intel.com>
---------------------------------------------------------------------
Intel Technology Poland sp. z o.o.
z siedziba w Gdansku
ul. Slowackiego 173
80-298 Gdansk

Sad Rejonowy Gdansk Polnoc w Gdansku, 
VII Wydzial Gospodarczy Krajowego Rejestru Sadowego, 
numer KRS 101882

NIP 957-07-52-316
Kapital zakladowy 200.000 zl

This e-mail and any attachments may contain confidential material for
the sole use of the intended recipient(s). Any review or distribution
by others is strictly prohibited. If you are not the intended
recipient, please contact the sender and delete all copies.

