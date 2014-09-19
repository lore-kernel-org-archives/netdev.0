From: Sathya Perla <sathya.perla@emulex.com>
Subject: [PATCH net-next 03/12] be2net: add speed reporting for 40G/KR interface
Date: Fri, 19 Sep 2014 15:46:53 +0530
Message-ID: <1411121822-25842-4-git-send-email-sathya.perla@emulex.com>
References: <1411121822-25842-1-git-send-email-sathya.perla@emulex.com>
Mime-Version: 1.0
Content-Type: text/plain
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cmexedge2.ext.emulex.com ([138.239.224.100]:53077 "EHLO
	CMEXEDGE2.ext.emulex.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755530AbaISKOa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Sep 2014 06:14:30 -0400
In-Reply-To: <1411121822-25842-1-git-send-email-sathya.perla@emulex.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Kalesh AP <kalesh.purayil@emulex.com>

This patch adds speed reporting via ethtool for 40Gbps KR4 interface
on the Skyhawk-R chip.

Signed-off-by: Kalesh AP <kalesh.purayil@emulex.com>
Signed-off-by: Sathya Perla <sathya.perla@emulex.com>
---
 drivers/net/ethernet/emulex/benet/be_ethtool.c |    7 +++++++
 1 files changed, 7 insertions(+), 0 deletions(-)

diff --git a/drivers/net/ethernet/emulex/benet/be_ethtool.c b/drivers/net/ethernet/emulex/benet/be_ethtool.c
index 43b5595..8297824 100644
--- a/drivers/net/ethernet/emulex/benet/be_ethtool.c
+++ b/drivers/net/ethernet/emulex/benet/be_ethtool.c
@@ -538,6 +538,13 @@ static u32 convert_to_et_setting(struct be_adapter *adapter, u32 if_speeds)
 		val |= SUPPORTED_Backplane |
 				SUPPORTED_10000baseKR_Full;
 		break;
+	case PHY_TYPE_KR4_40GB:
+		val |= SUPPORTED_Backplane;
+		if (if_speeds & BE_SUPPORTED_SPEED_10GBPS)
+			val |= SUPPORTED_10000baseKR_Full;
+		if (if_speeds & BE_SUPPORTED_SPEED_40GBPS)
+			val |= SUPPORTED_40000baseKR4_Full;
+		break;
 	case PHY_TYPE_QSFP:
 		if (if_speeds & BE_SUPPORTED_SPEED_40GBPS) {
 			switch (adapter->phy.cable_type) {
-- 
1.7.1
