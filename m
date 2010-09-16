From: Somnath Kotur <somnath.kotur@emulex.com>
Subject: [PATCH] net-2.6 be2net: fix to get RX IDs 0 and 1
Date: Thu, 16 Sep 2010 17:09:02 +0530
Message-ID: <20100916113842.GA3937@serverengines.com>
Reply-To: Somnath Kotur <somnath.kotur@emulex.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from segment-124-30.sify.net ([124.30.166.146]:45415 "EHLO
	akhaparde.serverengines.com" rhost-flags-OK-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S1753856Ab0IPLix (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Sep 2010 07:38:53 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Change made to allocate RX IDs 0 and 1 for the two ports.
To get RX Q IDs 0 and 1 enable RSS Capability for that interface.
RX IDs 0 and 1 have 32 bit drop counters which will take a long time
to wrap around thereby presenting a consistent stats display.

Signed-off-by: Somnath Kotur <somnath.kotur@emulex.com>
---
 drivers/net/benet/be_hw.h   |    6 ++++++
 drivers/net/benet/be_main.c |    2 ++
 2 files changed, 8 insertions(+), 0 deletions(-)

diff --git a/drivers/net/benet/be_hw.h b/drivers/net/benet/be_hw.h
index a2ec5df..e836ca6 100644
--- a/drivers/net/benet/be_hw.h
+++ b/drivers/net/benet/be_hw.h
@@ -52,6 +52,12 @@
  */
 #define MEMBAR_CTRL_INT_CTRL_HOSTINTR_MASK	(1 << 29) /* bit 29 */
 
+/********* PCI Function Capability ************/
+#define BE_FUNCTION_CAPS_UNCLASSIFIED_STATS	0x1
+#define BE_FUNCTION_CAPS_RSS			0x2
+#define BE_FUNCTION_CAPS_PROMISCUOUS		0x4
+#define BE_FUNCTION_CAPS_LEGACY_MODE		0x8
+
 /********* Power management (WOL) **********/
 #define PCICFG_PM_CONTROL_OFFSET		0x44
 #define PCICFG_PM_CONTROL_MASK			0x108	/* bits 3 & 8 */
diff --git a/drivers/net/benet/be_main.c b/drivers/net/benet/be_main.c
index 6eda7a0..f3cfb7b 100644
--- a/drivers/net/benet/be_main.c
+++ b/drivers/net/benet/be_main.c
@@ -2094,6 +2094,8 @@ static int be_setup(struct be_adapter *adapter)
 	cap_flags = en_flags = BE_IF_FLAGS_UNTAGGED | BE_IF_FLAGS_BROADCAST;
 
 	if (be_physfn(adapter)) {
+		if (adapter->function_caps & BE_FUNCTION_CAPS_RSS)
+			cap_flags |= BE_IF_FLAGS_RSS;
 		cap_flags |= BE_IF_FLAGS_MCAST_PROMISCUOUS |
 				BE_IF_FLAGS_PROMISCUOUS |
 				BE_IF_FLAGS_PASS_L3L4_ERRORS;
-- 
1.5.6.1

