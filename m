From: Yuval Mintz <Yuval.Mintz@cavium.com>
Subject: [PATCH net-next 4/7] qede: Decouple ethtool caps from qed
Date: Sun, 30 Oct 2016 18:38:34 +0200
Message-ID: <1477845517-17228-5-git-send-email-Yuval.Mintz@cavium.com>
References: <1477845517-17228-1-git-send-email-Yuval.Mintz@cavium.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Yuval Mintz <Yuval.Mintz@cavium.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-0016ce01.pphosted.com ([67.231.148.157]:40977 "EHLO
        mx0b-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1757202AbcJ3Qiw (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 30 Oct 2016 12:38:52 -0400
In-Reply-To: <1477845517-17228-1-git-send-email-Yuval.Mintz@cavium.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

While the qed_lm_maps is closely tied with the QED_LM_* defines,
when iterating over the array use actual size instead of the qed
define to prevent future possible issues.

Signed-off-by: Yuval Mintz <Yuval.Mintz@cavium.com>
---
 drivers/net/ethernet/qlogic/qede/qede_ethtool.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/qlogic/qede/qede_ethtool.c b/drivers/net/ethernet/qlogic/qede/qede_ethtool.c
index 42d9739..d230742 100644
--- a/drivers/net/ethernet/qlogic/qede/qede_ethtool.c
+++ b/drivers/net/ethernet/qlogic/qede/qede_ethtool.c
@@ -320,7 +320,7 @@ struct qede_link_mode_mapping {
 {								\
 	int i;							\
 								\
-	for (i = 0; i < QED_LM_COUNT; i++) {			\
+	for (i = 0; i < ARRAY_SIZE(qed_lm_map); i++) {		\
 		if ((caps) & (qed_lm_map[i].qed_link_mode))	\
 			__set_bit(qed_lm_map[i].ethtool_link_mode,\
 				  lk_ksettings->link_modes.name); \
@@ -331,7 +331,7 @@ struct qede_link_mode_mapping {
 {								\
 	int i;							\
 								\
-	for (i = 0; i < QED_LM_COUNT; i++) {			\
+	for (i = 0; i < ARRAY_SIZE(qed_lm_map); i++) {		\
 		if (test_bit(qed_lm_map[i].ethtool_link_mode,	\
 			     lk_ksettings->link_modes.name))	\
 			caps |= qed_lm_map[i].qed_link_mode;	\
-- 
1.9.3
