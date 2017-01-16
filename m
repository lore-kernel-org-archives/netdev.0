From: Shyam Saini <mayhs11saini@gmail.com>
Subject: [PATCH 1/2] qed: Replace memset with eth_zero_addr
Date: Mon, 16 Jan 2017 09:14:36 +0530
Message-ID: <1484538277-21376-1-git-send-email-mayhs11saini@gmail.com>
Cc: Ariel.Elior@cavium.com, everest-linux-l2@cavium.com,
        netdev@vger.kernel.org, Shyam Saini <mayhs11saini@gmail.com>
To: Yuval.Mintz@cavium.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f196.google.com ([209.85.192.196]:34062 "EHLO
        mail-pf0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750843AbdAPDo4 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 15 Jan 2017 22:44:56 -0500
Received: by mail-pf0-f196.google.com with SMTP id y143so13212673pfb.1
        for <netdev@vger.kernel.org>; Sun, 15 Jan 2017 19:44:55 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use eth_zero_addr to assign zero address to the given address array
instead of memset when the second argument in memset is address
of zero. Also, it makes the code clearer

Signed-off-by: Shyam Saini <mayhs11saini@gmail.com>
---
 drivers/net/ethernet/qlogic/qed/qed_l2.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/qlogic/qed/qed_l2.c b/drivers/net/ethernet/qlogic/qed/qed_l2.c
index 6a3727c..778c52c 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_l2.c
+++ b/drivers/net/ethernet/qlogic/qed/qed_l2.c
@@ -1776,7 +1776,7 @@ static int qed_fill_eth_dev_info(struct qed_dev *cdev,
 	qed_fill_dev_info(cdev, &info->common);
 
 	if (IS_VF(cdev))
-		memset(info->common.hw_mac, 0, ETH_ALEN);
+		eth_zero_addr(info->common.hw_mac);
 
 	return 0;
 }
-- 
2.7.4
