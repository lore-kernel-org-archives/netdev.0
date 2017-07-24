From: Stephen Hemminger <stephen@networkplumber.org>
Subject: [PATCH net-next 1/6] bnxt: fix unsigned comparsion with 0
Date: Mon, 24 Jul 2017 10:25:18 -0700
Message-ID: <20170724172523.13135-2-sthemmin@microsoft.com>
References: <20170724172523.13135-1-sthemmin@microsoft.com>
Cc: netdev@vger.kernel.org, linux-bluetooth@vger.kernel.org,
        netfilter-devel@vger.kernel.org, coreteam@netfilter.org,
        Stephen Hemminger <sthemmin@microsoft.com>
To: marcel@holtmann.org, gustavo@padovan.org, johan.hedberg@gmail.com,
        davem@davemloft.net, pablo@netfilter.org, kadlec@blackhole.kfki.hu,
        fw@strlen.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f54.google.com ([74.125.83.54]:37258 "EHLO
        mail-pg0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754821AbdGXRZc (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 24 Jul 2017 13:25:32 -0400
Received: by mail-pg0-f54.google.com with SMTP id y129so59794885pgy.4
        for <netdev@vger.kernel.org>; Mon, 24 Jul 2017 10:25:32 -0700 (PDT)
In-Reply-To: <20170724172523.13135-1-sthemmin@microsoft.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fixes warning because location is u32 and can never be netative
warning: comparison of unsigned expression < 0 is always false [-Wtype-limits]

Signed-off-by: Stephen Hemminger <sthemmin@microsoft.com>
---
 drivers/net/ethernet/broadcom/bnxt/bnxt_ethtool.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/broadcom/bnxt/bnxt_ethtool.c b/drivers/net/ethernet/broadcom/bnxt/bnxt_ethtool.c
index be6acadcb202..96b8c0db10f9 100644
--- a/drivers/net/ethernet/broadcom/bnxt/bnxt_ethtool.c
+++ b/drivers/net/ethernet/broadcom/bnxt/bnxt_ethtool.c
@@ -520,7 +520,7 @@ static int bnxt_grxclsrule(struct bnxt *bp, struct ethtool_rxnfc *cmd)
 	struct flow_keys *fkeys;
 	int i, rc = -EINVAL;
 
-	if (fs->location < 0 || fs->location >= BNXT_NTP_FLTR_MAX_FLTR)
+	if (fs->location >= BNXT_NTP_FLTR_MAX_FLTR)
 		return rc;
 
 	for (i = 0; i < BNXT_NTP_FLTR_HASH_SIZE; i++) {
-- 
2.11.0
