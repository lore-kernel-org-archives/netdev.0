From: Amit Kumar Salecha <amit.salecha@qlogic.com>
Subject: [PATCH 1/1] qlcnic: fix set mac addr
Date: Wed,  7 Apr 2010 04:01:54 -0700
Message-ID: <1270638114-15323-2-git-send-email-amit.salecha@qlogic.com>
References: <1270638114-15323-1-git-send-email-amit.salecha@qlogic.com>
Cc: netdev@vger.kernel.org, ameen.rahman@qlogic.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mvnat01.qlogic.com ([198.186.3.73]:62382 "HELO unm84.unmin.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with SMTP
	id S1752138Ab0DGLB4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 7 Apr 2010 07:01:56 -0400
In-Reply-To: <1270638114-15323-1-git-send-email-amit.salecha@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If interface is down, mac address request are not sent to fw
but it is getting add in driver mac list.
Driver mac list should be in sync with fw i.e addresses communicated
to fw.

Signed-off-by: Amit Kumar Salecha <amit.salecha@qlogic.com>
---
 drivers/net/qlcnic/qlcnic_hw.c |    3 +++
 1 files changed, 3 insertions(+), 0 deletions(-)

diff --git a/drivers/net/qlcnic/qlcnic_hw.c b/drivers/net/qlcnic/qlcnic_hw.c
index da00e16..b175313 100644
--- a/drivers/net/qlcnic/qlcnic_hw.c
+++ b/drivers/net/qlcnic/qlcnic_hw.c
@@ -430,6 +430,9 @@ void qlcnic_set_multi(struct net_device *netdev)
 	u8 bcast_addr[ETH_ALEN] = { 0xff, 0xff, 0xff, 0xff, 0xff, 0xff };
 	u32 mode = VPORT_MISS_MODE_DROP;
 
+	if (adapter->is_up != QLCNIC_ADAPTER_UP_MAGIC)
+		return;
+
 	qlcnic_nic_add_mac(adapter, adapter->mac_addr);
 	qlcnic_nic_add_mac(adapter, bcast_addr);
 
-- 
1.6.0.2

