From: "K. Y. Srinivasan" <kys@microsoft.com>
Subject: [PATCH net 1/1] hv_netvsc: Fix a bug in netvsc_start_xmit()
Date: Mon, 27 Apr 2015 18:14:50 -0700
Message-ID: <1430183690-24198-1-git-send-email-kys@microsoft.com>
Cc: "K. Y. Srinivasan" <kys@microsoft.com>
To: davem@davemloft.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, devel@linuxdriverproject.org,
	olaf@aepfle.de, apw@canonical.com, jasowang@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from p3plsmtps2ded01.prod.phx3.secureserver.net ([208.109.80.58]:37122
	"EHLO p3plsmtps2ded01.prod.phx3.secureserver.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752457AbbD0Xzy (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 27 Apr 2015 19:55:54 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Commit commit b08cc79155fc26d0d112b1470d1ece5034651a4b eliminated memory
allocation in the packet send path. This commit introduced a bug since it
did not account for the case if the skb was cloned. Fix this bug by
using the pre-reserved head room only if the skb is not cloned.

Signed-off-by: K. Y. Srinivasan <kys@microsoft.com>
---
 drivers/net/hyperv/netvsc_drv.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/hyperv/netvsc_drv.c b/drivers/net/hyperv/netvsc_drv.c
index a3a9d38..7eb0251 100644
--- a/drivers/net/hyperv/netvsc_drv.c
+++ b/drivers/net/hyperv/netvsc_drv.c
@@ -421,7 +421,7 @@ check_size:
 
 	pkt_sz = sizeof(struct hv_netvsc_packet) + RNDIS_AND_PPI_SIZE;
 
-	if (head_room < pkt_sz) {
+	if (skb->cloned ||  head_room < pkt_sz) {
 		packet = kmalloc(pkt_sz, GFP_ATOMIC);
 		if (!packet) {
 			/* out of memory, drop packet */
-- 
1.7.4.1
