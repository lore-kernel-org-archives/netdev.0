From: Casey Leedom <leedom@chelsio.com>
Subject: [PATCH net-next 3/4] cxgb3: Leave interrupts for fatal errors asserted in common code.
Date: Thu,  2 Sep 2010 16:07:31 -0700
Message-ID: <1283468852-1010-3-git-send-email-leedom@chelsio.com>
References: <241D2F16-4F92-48DD-A904-832771B2F4B4@chelsio.com>
Cc: Casey Leedom <leedom@chelsio.com>,
	Dimitris Michailidis <dm@chelsio.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([67.207.112.58]:1606 "EHLO
	stargate.chelsio.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756722Ab0IBXHi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Sep 2010 19:07:38 -0400
In-Reply-To: <241D2F16-4F92-48DD-A904-832771B2F4B4@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Platform code needs to deal with them now.

Signed-off-by: Dimitris Michailidis <dm@chelsio.com>
Signed-off-by: Casey Leedom <leedom@chelsio.com>
---
 drivers/net/cxgb3/t3_hw.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/cxgb3/t3_hw.c b/drivers/net/cxgb3/t3_hw.c
index 14a5664..d307c9d 100644
--- a/drivers/net/cxgb3/t3_hw.c
+++ b/drivers/net/cxgb3/t3_hw.c
@@ -1408,6 +1408,7 @@ static int t3_handle_intr_status(struct adapter *adapter, unsigned int reg,
 			fatal++;
 			CH_ALERT(adapter, "%s (0x%x)\n",
 				 acts->msg, status & acts->mask);
+			status &= ~acts->mask;
 		} else if (acts->msg)
 			CH_WARN(adapter, "%s (0x%x)\n",
 				acts->msg, status & acts->mask);
@@ -1843,11 +1844,10 @@ static int mac_intr_handler(struct adapter *adap, unsigned int idx)
 		t3_os_link_fault_handler(adap, idx);
 	}
 
-	t3_write_reg(adap, A_XGM_INT_CAUSE + mac->offset, cause);
-
 	if (cause & XGM_INTR_FATAL)
 		t3_fatal_err(adap);
 
+	t3_write_reg(adap, A_XGM_INT_CAUSE + mac->offset, cause);
 	return cause != 0;
 }
 
-- 
1.7.0.4

