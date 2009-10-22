From: Dhananjay Phadke <dhananjay@netxen.com>
Subject: [PATCH 2/3] netxen: fix tx timeout handling on firmware hang
Date: Wed, 21 Oct 2009 22:39:02 -0700
Message-ID: <1256189943-20477-3-git-send-email-dhananjay@netxen.com>
References: <1256189943-20477-1-git-send-email-dhananjay@netxen.com>
Cc: netdev@vger.kernel.org,
	Amit Kumar Salecha <amit.salecha@qlogic.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mvnat01.qlogic.com ([198.186.3.73]:24198 "HELO unm84.unmin.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with SMTP
	id S1752026AbZJVFjA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 22 Oct 2009 01:39:00 -0400
In-Reply-To: <1256189943-20477-1-git-send-email-dhananjay@netxen.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Amit Kumar Salecha <amit.salecha@qlogic.com>

Clear NX_RESETING bit in netxen_tx_timeout_task() so that
the firmware watchdog task can catch need_reset request
from tx timeout.

Signed-off-by: Amit Kumar Salecha <amit.salecha@qlogic.com>
Signed-off-by: Dhananjay Phadke <dhananjay@netxen.com>
---
 drivers/net/netxen/netxen_nic_main.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/drivers/net/netxen/netxen_nic_main.c b/drivers/net/netxen/netxen_nic_main.c
index 7fc15e9..0b4a56a 100644
--- a/drivers/net/netxen/netxen_nic_main.c
+++ b/drivers/net/netxen/netxen_nic_main.c
@@ -1919,6 +1919,7 @@ static void netxen_tx_timeout_task(struct work_struct *work)
 
 request_reset:
 	adapter->need_fw_reset = 1;
+	clear_bit(__NX_RESETTING, &adapter->state);
 }
 
 struct net_device_stats *netxen_nic_get_stats(struct net_device *netdev)
-- 
1.6.0.2

