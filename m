From: Amit Kumar Salecha <amit.salecha@qlogic.com>
Subject: [PATCH net-2.6 3/4] netxen: fix set mac addr
Date: Fri,  8 Jan 2010 00:10:16 -0800
Message-ID: <1262938217-10089-4-git-send-email-amit.salecha@qlogic.com>
References: <1262938217-10089-1-git-send-email-amit.salecha@qlogic.com>
Cc: netdev@vger.kernel.org, dhananjay.phadke@qlogic.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mvnat01.qlogic.com ([198.186.3.73]:25995 "HELO unm84.unmin.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with SMTP
	id S1753171Ab0AHIKV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 8 Jan 2010 03:10:21 -0500
In-Reply-To: <1262938217-10089-1-git-send-email-amit.salecha@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

o If tx and rx resources are not available, during set mac request.
  Then this request wont be passed to firmware and it will be added to
  driver mac list and will never make it to firmware.
  So if resources are not available, don't add it to driver mac list.

Signed-off-by: Amit Kumar Salecha <amit.salecha@qlogic.com>
---
 drivers/net/netxen/netxen_nic_hw.c |    3 +++
 1 files changed, 3 insertions(+), 0 deletions(-)

diff --git a/drivers/net/netxen/netxen_nic_hw.c b/drivers/net/netxen/netxen_nic_hw.c
index 398dfd4..85e28e6 100644
--- a/drivers/net/netxen/netxen_nic_hw.c
+++ b/drivers/net/netxen/netxen_nic_hw.c
@@ -690,6 +690,9 @@ void netxen_p3_nic_set_multi(struct net_device *netdev)
 	struct list_head *head;
 	nx_mac_list_t *cur;
 
+	if (adapter->is_up != NETXEN_ADAPTER_UP_MAGIC)
+		return;
+
 	list_splice_tail_init(&adapter->mac_list, &del_list);
 
 	nx_p3_nic_add_mac(adapter, adapter->mac_addr, &del_list);
-- 
1.6.0.2

