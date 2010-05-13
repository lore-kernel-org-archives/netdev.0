From: Amit Kumar Salecha <amit.salecha@qlogic.com>
Subject: [PATCH NEXT 1/9] qlcnic: fix context cleanup
Date: Thu, 13 May 2010 06:07:42 -0700
Message-ID: <1273756070-7205-2-git-send-email-amit.salecha@qlogic.com>
References: <1273756070-7205-1-git-send-email-amit.salecha@qlogic.com>
Cc: netdev@vger.kernel.org, ameen.rahman@qlogic.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mvnat01.qlogic.com ([198.186.3.73]:55907 "HELO unm84.unmin.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with SMTP
	id S1758568Ab0EMNHx (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 13 May 2010 09:07:53 -0400
In-Reply-To: <1273756070-7205-1-git-send-email-amit.salecha@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Before going for recovery, every pci-func should check fw state,
irrespective of device state. This to avoid unnecssary sending
of command for ctx destroy.

Signed-off-by: Amit Kumar Salecha <amit.salecha@qlogic.com>
---
 drivers/net/qlcnic/qlcnic_main.c |    4 +---
 1 files changed, 1 insertions(+), 3 deletions(-)

diff --git a/drivers/net/qlcnic/qlcnic_main.c b/drivers/net/qlcnic/qlcnic_main.c
index ee573fe..dc791d5 100644
--- a/drivers/net/qlcnic/qlcnic_main.c
+++ b/drivers/net/qlcnic/qlcnic_main.c
@@ -2302,10 +2302,8 @@ qlcnic_check_health(struct qlcnic_adapter *adapter)
 	if (qlcnic_check_temp(adapter))
 		goto detach;
 
-	if (adapter->need_fw_reset) {
+	if (adapter->need_fw_reset)
 		qlcnic_dev_request_reset(adapter);
-		goto detach;
-	}
 
 	state = QLCRD32(adapter, QLCNIC_CRB_DEV_STATE);
 	if (state == QLCNIC_DEV_NEED_RESET || state == QLCNIC_DEV_NEED_QUISCENT)
-- 
1.6.0.2

