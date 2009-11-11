From: Ron Mercer <ron.mercer@qlogic.com>
Subject: [net-next PATCH 2/4] qlge: Add asic reset to open call.
Date: Wed, 11 Nov 2009 14:54:04 -0800
Message-ID: <1257980046-2420-3-git-send-email-ron.mercer@qlogic.com>
References: <1257980046-2420-1-git-send-email-ron.mercer@qlogic.com>
Cc: netdev@vger.kernel.org, ron.mercer@qlogic.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from avexch1.qlogic.com ([198.70.193.115]:24232 "EHLO
	avexch1.qlogic.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759468AbZKKXAf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Nov 2009 18:00:35 -0500
In-Reply-To: <1257980046-2420-1-git-send-email-ron.mercer@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Force asic to known state at open().

Signed-off-by: Ron Mercer <ron.mercer@qlogic.com>
---
 drivers/net/qlge/qlge_main.c |    4 ++++
 1 files changed, 4 insertions(+), 0 deletions(-)

diff --git a/drivers/net/qlge/qlge_main.c b/drivers/net/qlge/qlge_main.c
index 2bfa783..d2a4bbe 100644
--- a/drivers/net/qlge/qlge_main.c
+++ b/drivers/net/qlge/qlge_main.c
@@ -3714,6 +3714,10 @@ static int qlge_open(struct net_device *ndev)
 	int err = 0;
 	struct ql_adapter *qdev = netdev_priv(ndev);
 
+	err = ql_adapter_reset(qdev);
+	if (err)
+		return err;
+
 	err = ql_configure_rings(qdev);
 	if (err)
 		return err;
-- 
1.6.0.2

