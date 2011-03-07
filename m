From: Padmanabh Ratnakar <padmanabh.ratnakar@emulex.com>
Subject: [PATCH net-next-2.6 7/7] be2net: Add multicast filter capability for Lancer
Date: Mon, 7 Mar 2011 18:39:36 +0530
Message-ID: <75dc2dd0-70ff-4ce2-b42e-6bbebb4f257b@exht1.ad.emulex.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Padmanabh Ratnakar <padmanabh.ratnakar@emulex.com>,
	Sathya Perla <sathya.perla@emulex.com>,
	Subramanian Seetharaman <subbu.seetharaman@emulex.com>
To: <netdev@vger.kernel.org>, <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exht1.emulex.com ([138.239.113.183]:52353 "EHLO
	exht1.ad.emulex.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751701Ab1CGNKd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Mar 2011 08:10:33 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Lancer requires multicast capability flag set during IFACE_CREATE
for adding multicast filters.

Signed-off-by: Padmanabh Ratnakar <padmanabh.ratnakar@emulex.com>
Signed-off-by: Sathya Perla <sathya.perla@emulex.com>
Signed-off-by: Subramanian Seetharaman <subbu.seetharaman@emulex.com>
---
 drivers/net/benet/be_cmds.h |    3 ++-
 drivers/net/benet/be_main.c |    4 +++-
 2 files changed, 5 insertions(+), 2 deletions(-)

diff --git a/drivers/net/benet/be_cmds.h b/drivers/net/benet/be_cmds.h
index 5bdaa22..b4ac393 100644
--- a/drivers/net/benet/be_cmds.h
+++ b/drivers/net/benet/be_cmds.h
@@ -518,7 +518,8 @@ enum be_if_flags {
 	BE_IF_FLAGS_VLAN = 0x100,
 	BE_IF_FLAGS_MCAST_PROMISCUOUS = 0x200,
 	BE_IF_FLAGS_PASS_L2_ERRORS = 0x400,
-	BE_IF_FLAGS_PASS_L3L4_ERRORS = 0x800
+	BE_IF_FLAGS_PASS_L3L4_ERRORS = 0x800,
+	BE_IF_FLAGS_MULTICAST = 0x1000
 };
 
 /* An RX interface is an object with one or more MAC addresses and
diff --git a/drivers/net/benet/be_main.c b/drivers/net/benet/be_main.c
index a7fd833..68f1078 100644
--- a/drivers/net/benet/be_main.c
+++ b/drivers/net/benet/be_main.c
@@ -2263,7 +2263,9 @@ static int be_setup(struct be_adapter *adapter)
 	int status;
 	u8 mac[ETH_ALEN];
 
-	cap_flags = en_flags = BE_IF_FLAGS_UNTAGGED | BE_IF_FLAGS_BROADCAST;
+	cap_flags = en_flags = BE_IF_FLAGS_UNTAGGED |
+				BE_IF_FLAGS_BROADCAST |
+				BE_IF_FLAGS_MULTICAST;
 
 	if (be_physfn(adapter)) {
 		cap_flags |= BE_IF_FLAGS_MCAST_PROMISCUOUS |
-- 
1.6.0.2

