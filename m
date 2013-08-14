From: <sarveshwar.bandi@emulex.com>
Subject: [PATCH net v2] be2net: Clear any capability flags that driver is not interested in.
Date: Wed, 14 Aug 2013 13:21:47 +0530
Message-ID: <07165eb6-9b8f-45b4-bec6-bb53f0e1aa52@CMEXHTCAS2.ad.emulex.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>,
	Sarveshwar Bandi <sarveshwar.bandi@emulex.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cmexedge1.ext.emulex.com ([138.239.224.99]:5151 "EHLO
	CMEXEDGE1.ext.emulex.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757923Ab3HNHus (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Aug 2013 03:50:48 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sarveshwar Bandi <sarveshwar.bandi@emulex.com>

It is possible for some versions of firmware to advertise capabilities that driver
is not ready to handle. This may lead to controller stall. Since the driver is
interested only in subset of flags, clearing the rest.

Signed-off-by: Sarveshwar Bandi <sarveshwar.bandi@emulex.com>
---
 drivers/net/ethernet/emulex/benet/be_cmds.c |    3 +++
 drivers/net/ethernet/emulex/benet/be_cmds.h |    6 ++++++
 2 files changed, 9 insertions(+)

diff --git a/drivers/net/ethernet/emulex/benet/be_cmds.c b/drivers/net/ethernet/emulex/benet/be_cmds.c
index 6e6e0a1..8ec5d74 100644
--- a/drivers/net/ethernet/emulex/benet/be_cmds.c
+++ b/drivers/net/ethernet/emulex/benet/be_cmds.c
@@ -3048,6 +3048,9 @@ int be_cmd_get_func_config(struct be_adapter *adapter)
 
 		adapter->max_event_queues = le16_to_cpu(desc->eq_count);
 		adapter->if_cap_flags = le32_to_cpu(desc->cap_flags);
+
+		/* Clear flags that driver is not interested in */
+		adapter->if_cap_flags &=  BE_IF_CAP_FLAGS_WANT;
 	}
 err:
 	mutex_unlock(&adapter->mbox_lock);
diff --git a/drivers/net/ethernet/emulex/benet/be_cmds.h b/drivers/net/ethernet/emulex/benet/be_cmds.h
index 5228d88..1b3b9e8 100644
--- a/drivers/net/ethernet/emulex/benet/be_cmds.h
+++ b/drivers/net/ethernet/emulex/benet/be_cmds.h
@@ -563,6 +563,12 @@ enum be_if_flags {
 	BE_IF_FLAGS_MULTICAST = 0x1000
 };
 
+#define BE_IF_CAP_FLAGS_WANT (BE_IF_FLAGS_RSS | BE_IF_FLAGS_PROMISCUOUS |\
+			 BE_IF_FLAGS_BROADCAST | BE_IF_FLAGS_VLAN_PROMISCUOUS |\
+			 BE_IF_FLAGS_VLAN | BE_IF_FLAGS_MCAST_PROMISCUOUS |\
+			 BE_IF_FLAGS_PASS_L3L4_ERRORS | BE_IF_FLAGS_MULTICAST |\
+			 BE_IF_FLAGS_UNTAGGED)
+
 /* An RX interface is an object with one or more MAC addresses and
  * filtering capabilities. */
 struct be_cmd_req_if_create {
-- 
1.7.9.5
