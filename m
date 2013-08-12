From: <sarveshwar.bandi@emulex.com>
Subject: [PATCH net] be2net: Clear any capability flags that driver is not interested in.
Date: Mon, 12 Aug 2013 11:21:09 +0530
Message-ID: <208f9dff-8e74-4a44-bd94-6c79342e6a73@CMEXHTCAS1.ad.emulex.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>,
	Sarveshwar Bandi <sarveshwar.bandi@emulex.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cmexedge2.ext.emulex.com ([138.239.224.100]:26098 "EHLO
	CMEXEDGE2.ext.emulex.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755803Ab3HLFuO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 Aug 2013 01:50:14 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sarveshwar Bandi <sarveshwar.bandi@emulex.com>

It is possible for some versions of firmware to advertise capabilities that driver
is not ready to handle. This may lead to controller stall. Clear all flags that driver
is not interested in.

Signed-off-by: Sarveshwar Bandi <sarveshwar.bandi@emulex.com>
---
 drivers/net/ethernet/emulex/benet/be_cmds.h |    6 ++++++
 drivers/net/ethernet/emulex/benet/be_main.c |    2 ++
 2 files changed, 8 insertions(+)

diff --git a/drivers/net/ethernet/emulex/benet/be_cmds.h b/drivers/net/ethernet/emulex/benet/be_cmds.h
index 5228d88..8fba7dd 100644
--- a/drivers/net/ethernet/emulex/benet/be_cmds.h
+++ b/drivers/net/ethernet/emulex/benet/be_cmds.h
@@ -563,6 +563,12 @@ enum be_if_flags {
 	BE_IF_FLAGS_MULTICAST = 0x1000
 };
 
+#define BE_IF_CAP_FLAGS (BE_IF_FLAGS_RSS | BE_IF_FLAGS_PROMISCUOUS |\
+			 BE_IF_FLAGS_BROADCAST | BE_IF_FLAGS_VLAN_PROMISCUOUS |\
+			 BE_IF_FLAGS_VLAN | BE_IF_FLAGS_MCAST_PROMISCUOUS |\
+			 BE_IF_FLAGS_PASS_L3L4_ERRORS | BE_IF_FLAGS_MULTICAST |\
+			 BE_IF_FLAGS_UNTAGGED)
+
 /* An RX interface is an object with one or more MAC addresses and
  * filtering capabilities. */
 struct be_cmd_req_if_create {
diff --git a/drivers/net/ethernet/emulex/benet/be_main.c b/drivers/net/ethernet/emulex/benet/be_main.c
index 181edb5..8d7ee2e 100644
--- a/drivers/net/ethernet/emulex/benet/be_main.c
+++ b/drivers/net/ethernet/emulex/benet/be_main.c
@@ -3044,6 +3044,8 @@ static void be_get_resources(struct be_adapter *adapter)
 		if (adapter->max_event_queues < adapter->max_rss_queues)
 			adapter->max_rss_queues = adapter->max_event_queues;
 
+		/* Clear flags that driver is not interested in */
+		adapter->if_cap_flags &=  BE_IF_CAP_FLAGS;
 	} else {
 		if (be_physfn(adapter))
 			adapter->max_pmac_cnt = BE_UC_PMAC_COUNT;
-- 
1.7.9.5
