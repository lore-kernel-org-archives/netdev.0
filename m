From: Amit Kumar Salecha <amit.salecha@qlogic.com>
Subject: [PATCHv2 NEXT 2/2] qlcnic: fix diag resource allocation
Date: Sat, 24 Jul 2010 21:32:18 -0700
Message-ID: <1280032338-7002-3-git-send-email-amit.salecha@qlogic.com>
References: <1280032338-7002-1-git-send-email-amit.salecha@qlogic.com>
Cc: netdev@vger.kernel.org, ameen.rahman@qlogic.com,
	Sony Chacko <sony.chacko@qlogic.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mvnat01.qlogic.com ([198.186.3.73]:52281 "HELO unm84.unmin.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with SMTP
	id S1751082Ab0GYEcT (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 25 Jul 2010 00:32:19 -0400
In-Reply-To: <1280032338-7002-1-git-send-email-amit.salecha@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sony Chacko <sony.chacko@qlogic.com>

netif_device_attach missing from error path in qlcnic_diag_alloc_res

Signed-off-by: Sony Chacko <sony.chacko@qlogic.com>
Signed-off-by: Amit Kumar Salecha <amit.salecha@qlogic.com>
---
 drivers/net/qlcnic/qlcnic_main.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/drivers/net/qlcnic/qlcnic_main.c b/drivers/net/qlcnic/qlcnic_main.c
index f147958..b9615bd 100644
--- a/drivers/net/qlcnic/qlcnic_main.c
+++ b/drivers/net/qlcnic/qlcnic_main.c
@@ -1176,6 +1176,7 @@ int qlcnic_diag_alloc_res(struct net_device *netdev, int test)
 	ret = qlcnic_fw_create_ctx(adapter);
 	if (ret) {
 		qlcnic_detach(adapter);
+		netif_device_attach(netdev);
 		return ret;
 	}
 
-- 
1.6.0.2

