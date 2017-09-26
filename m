From: Tobias Klauser <tklauser@distanz.ch>
Subject: [PATCH net-next] ldmvsw: Remove redundant unlikely()
Date: Tue, 26 Sep 2017 15:14:15 +0200
Message-ID: <20170926131415.8649-1-tklauser@distanz.ch>
Cc: "David S. Miller" <davem@davemloft.net>,
        Shannon Nelson <shannon.nelson@oracle.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.zhinst.com ([212.126.164.98]:51040 "EHLO mail.zhinst.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S967312AbdIZNOS (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 26 Sep 2017 09:14:18 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

IS_ERR() already implies unlikely(), so it can be omitted.

Signed-off-by: Tobias Klauser <tklauser@distanz.ch>
---
 drivers/net/ethernet/sun/ldmvsw.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/sun/ldmvsw.c b/drivers/net/ethernet/sun/ldmvsw.c
index 5b56c24b6ed2..5feeaa9f0a9e 100644
--- a/drivers/net/ethernet/sun/ldmvsw.c
+++ b/drivers/net/ethernet/sun/ldmvsw.c
@@ -307,7 +307,7 @@ static int vsw_port_probe(struct vio_dev *vdev, const struct vio_device_id *id)
 
 	/* Get (or create) the vnet associated with this port */
 	vp = vsw_get_vnet(hp, vdev->mp, &handle);
-	if (unlikely(IS_ERR(vp))) {
+	if (IS_ERR(vp)) {
 		err = PTR_ERR(vp);
 		pr_err("Failed to get vnet for vsw-port\n");
 		mdesc_release(hp);
-- 
2.13.0
