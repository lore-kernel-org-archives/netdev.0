From: Yuval Mintz <Yuval.Mintz@qlogic.com>
Subject: [PATCH net-next 1/2] qed*: Fix pause setting
Date: Fri, 19 Aug 2016 08:34:57 +0300
Message-ID: <1471584898-23253-2-git-send-email-Yuval.Mintz@qlogic.com>
References: <1471584898-23253-1-git-send-email-Yuval.Mintz@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Yuval Mintz <Yuval.Mintz@qlogic.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-0016ce01.pphosted.com ([67.231.148.157]:49855 "EHLO
        mx0b-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1753576AbcHSFfJ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 19 Aug 2016 01:35:09 -0400
In-Reply-To: <1471584898-23253-1-git-send-email-Yuval.Mintz@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When moving into using ethtool's link_ksetting, qed started
supplying its own bitmask of speed/capabilities, but qede
is still checking for the SUPPORTED value to determine whether
it supports pause.

Fixes: 054c67d1c82a ("qed*: Add support for ethtool link_ksettings callbacks")
Signed-off-by: Yuval Mintz <Yuval.Mintz@qlogic.com>
---
 drivers/net/ethernet/qlogic/qede/qede_ethtool.c | 2 +-
 include/linux/qed/qed_if.h                      | 8 +++++---
 2 files changed, 6 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/qlogic/qede/qede_ethtool.c b/drivers/net/ethernet/qlogic/qede/qede_ethtool.c
index f0ab2fd..ef521e5 100644
--- a/drivers/net/ethernet/qlogic/qede/qede_ethtool.c
+++ b/drivers/net/ethernet/qlogic/qede/qede_ethtool.c
@@ -672,7 +672,7 @@ static int qede_set_pauseparam(struct net_device *dev,
 	memset(&params, 0, sizeof(params));
 	params.override_flags |= QED_LINK_OVERRIDE_PAUSE_CONFIG;
 	if (epause->autoneg) {
-		if (!(current_link.supported_caps & SUPPORTED_Autoneg)) {
+		if (!(current_link.supported_caps & QED_LM_Autoneg_BIT)) {
 			DP_INFO(edev, "autoneg not supported\n");
 			return -EINVAL;
 		}
diff --git a/include/linux/qed/qed_if.h b/include/linux/qed/qed_if.h
index 864265f..433e33a 100644
--- a/include/linux/qed/qed_if.h
+++ b/include/linux/qed/qed_if.h
@@ -314,9 +314,11 @@ struct qed_link_params {
 struct qed_link_output {
 	bool	link_up;
 
-	u32	supported_caps;         /* In SUPPORTED defs */
-	u32	advertised_caps;        /* In ADVERTISED defs */
-	u32	lp_caps;                /* In ADVERTISED defs */
+	/* In QED_LM_* defs */
+	u32	supported_caps;
+	u32	advertised_caps;
+	u32	lp_caps;
+
 	u32	speed;                  /* In Mb/s */
 	u8	duplex;                 /* In DUPLEX defs */
 	u8	port;                   /* In PORT defs */
-- 
1.9.3
