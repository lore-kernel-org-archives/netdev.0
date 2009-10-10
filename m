From: Ron Mercer <ron.mercer@qlogic.com>
Subject: [net-next PATCH 7/8] qlge: Don't fail open when port is not initialized.
Date: Sat, 10 Oct 2009 12:35:09 -0700
Message-ID: <1255203310-18114-8-git-send-email-ron.mercer@qlogic.com>
References: <1255203310-18114-1-git-send-email-ron.mercer@qlogic.com>
Cc: netdev@vger.kernel.org, ron.mercer@qlogic.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from avexch1.qlogic.com ([198.70.193.115]:55225 "EHLO
	avexch1.qlogic.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S934787AbZJJTnb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 10 Oct 2009 15:43:31 -0400
In-Reply-To: <1255203310-18114-1-git-send-email-ron.mercer@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Signed-off-by: Ron Mercer <ron.mercer@qlogic.com>
---
 drivers/net/qlge/qlge_main.c |    6 ++----
 1 files changed, 2 insertions(+), 4 deletions(-)

diff --git a/drivers/net/qlge/qlge_main.c b/drivers/net/qlge/qlge_main.c
index 09247ab..9eefb11 100644
--- a/drivers/net/qlge/qlge_main.c
+++ b/drivers/net/qlge/qlge_main.c
@@ -3310,10 +3310,8 @@ static int ql_adapter_initialize(struct ql_adapter *qdev)
 
 	/* Initialize the port and set the max framesize. */
 	status = qdev->nic_ops->port_initialize(qdev);
-       if (status) {
-              QPRINTK(qdev, IFUP, ERR, "Failed to start port.\n");
-              return status;
-       }
+	if (status)
+		QPRINTK(qdev, IFUP, ERR, "Failed to start port.\n");
 
 	/* Set up the MAC address and frame routing filter. */
 	status = ql_cam_route_initialize(qdev);
-- 
1.6.0.2

