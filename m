From: Dhananjay Phadke <dhananjay@netxen.com>
Subject: [PATCH 2/2] netxen: fix firmware init after resume
Date: Sun, 20 Sep 2009 22:20:39 -0700
Message-ID: <1253510439-28464-2-git-send-email-dhananjay@netxen.com>
References: <1253510439-28464-1-git-send-email-dhananjay@netxen.com>
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mvnat01.qlogic.com ([198.186.3.73]:61690 "HELO unm84.unmin.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with SMTP
	id S1753759AbZIUFUh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 21 Sep 2009 01:20:37 -0400
In-Reply-To: <1253510439-28464-1-git-send-email-dhananjay@netxen.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

After successful firmware init, return instead of
falling to error path (leading to detach) after
resuming to D0 state. This was broken in recent
firmware reset rehaul.

Signed-off-by: Dhananjay Phadke <dhananjay@netxen.com>
---
 drivers/net/netxen/netxen_nic_main.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/drivers/net/netxen/netxen_nic_main.c b/drivers/net/netxen/netxen_nic_main.c
index b8c7235..b5aa974 100644
--- a/drivers/net/netxen/netxen_nic_main.c
+++ b/drivers/net/netxen/netxen_nic_main.c
@@ -1469,6 +1469,7 @@ netxen_nic_resume(struct pci_dev *pdev)
 	}
 
 	netxen_schedule_work(adapter, netxen_fw_poll_work, FW_POLL_DELAY);
+	return 0;
 
 err_out_detach:
 	netxen_nic_detach(adapter);
-- 
1.6.0.2

