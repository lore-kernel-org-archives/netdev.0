From: Yuval Mintz <Yuval.Mintz@qlogic.com>
Subject: [PATCH net-next 2/2] qede: Fix forcing high speeds
Date: Fri, 19 Aug 2016 08:34:58 +0300
Message-ID: <1471584898-23253-3-git-send-email-Yuval.Mintz@qlogic.com>
References: <1471584898-23253-1-git-send-email-Yuval.Mintz@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Yuval Mintz <Yuval.Mintz@qlogic.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-0016ce01.pphosted.com ([67.231.156.153]:46259 "EHLO
        mx0b-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1754765AbcHSFfR (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 19 Aug 2016 01:35:17 -0400
In-Reply-To: <1471584898-23253-1-git-send-email-Yuval.Mintz@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

While '0xdead' and '0xbeef' are "great" values, we should
use the correct SPEED_* values instead.

Fixes: 054c67d1c82a ("qed*: Add support for ethtool link_ksettings callbacks")
Signed-off-by: Yuval Mintz <Yuval.Mintz@qlogic.com>
---
 drivers/net/ethernet/qlogic/qede/qede_ethtool.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/qlogic/qede/qede_ethtool.c b/drivers/net/ethernet/qlogic/qede/qede_ethtool.c
index ef521e5..c1a4c98 100644
--- a/drivers/net/ethernet/qlogic/qede/qede_ethtool.c
+++ b/drivers/net/ethernet/qlogic/qede/qede_ethtool.c
@@ -414,7 +414,7 @@ static int qede_set_link_ksettings(struct net_device *dev,
 			}
 			params.adv_speeds = QED_LM_40000baseLR4_Full_BIT;
 			break;
-		case 0xdead:
+		case SPEED_50000:
 			if (!(current_link.supported_caps &
 			      QED_LM_50000baseKR2_Full_BIT)) {
 				DP_INFO(edev, "50G speed not supported\n");
@@ -422,7 +422,7 @@ static int qede_set_link_ksettings(struct net_device *dev,
 			}
 			params.adv_speeds = QED_LM_50000baseKR2_Full_BIT;
 			break;
-		case 0xbeef:
+		case SPEED_100000:
 			if (!(current_link.supported_caps &
 			      QED_LM_100000baseKR4_Full_BIT)) {
 				DP_INFO(edev, "100G speed not supported\n");
-- 
1.9.3
