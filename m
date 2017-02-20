From: Pavel Belous <Pavel.Belous@aquantia.com>
Subject: [PATCH net-next v4 11/12] net: ethernet: aquantia: Fixed memory allocation if AQ_CFG_RX_FRAME_MAX > 1 page.
Date: Mon, 20 Feb 2017 22:36:49 +0300
Message-ID: <5054377b309946754e7165da7a327954a24ef501.1487618263.git.pavel.belous@aquantia.com>
References: <cover.1487618263.git.pavel.belous@aquantia.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: netdev@vger.kernel.org,
        Simon Edelhaus <Simon.Edelhaus@aquantia.com>,
        Alexey Andriyanov <Alexey.Andriyanov@aquantia.com>,
        Lino Sanfilippo <LinoSanfilippo@gmx.de>,
        Pavel Belous <pavel.belous@aquantia.com>
To: "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bl2nam02on0068.outbound.protection.outlook.com ([104.47.38.68]:52795
        "EHLO NAM02-BL2-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1752349AbdBTTiI (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 20 Feb 2017 14:38:08 -0500
In-Reply-To: <cover.1487618263.git.pavel.belous@aquantia.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Pavel Belous <pavel.belous@aquantia.com>

We should allocate the number of pages based on the config parameter
AQ_CFG_RX_FRAME_MAX.

Signed-off-by: Pavel Belous <pavel.belous@aquantia.com>
---
 drivers/net/ethernet/aquantia/atlantic/aq_ring.c | 4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/aquantia/atlantic/aq_ring.c b/drivers/net/ethernet/aquantia/atlantic/aq_ring.c
index 22bb75e..51f4e7f 100644
--- a/drivers/net/ethernet/aquantia/atlantic/aq_ring.c
+++ b/drivers/net/ethernet/aquantia/atlantic/aq_ring.c
@@ -270,6 +270,8 @@ int aq_ring_rx_clean(struct aq_ring_s *self, int *work_done, int budget)
 
 int aq_ring_rx_fill(struct aq_ring_s *self)
 {
+	unsigned int pages_order = fls(AQ_CFG_RX_FRAME_MAX / PAGE_SIZE +
+		(AQ_CFG_RX_FRAME_MAX % PAGE_SIZE ? 1 : 0)) - 1;
 	struct aq_ring_buff_s *buff = NULL;
 	int err = 0;
 	int i = 0;
@@ -282,7 +284,7 @@ int aq_ring_rx_fill(struct aq_ring_s *self)
 		buff->len = AQ_CFG_RX_FRAME_MAX;
 
 		buff->page = alloc_pages(GFP_ATOMIC | __GFP_COLD |
-					 __GFP_COMP, 0);
+					 __GFP_COMP, pages_order);
 		if (!buff->page) {
 			err = -ENOMEM;
 			goto err_exit;
-- 
2.7.4
