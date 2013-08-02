From: Peter Wu <lekensteyn@gmail.com>
Subject: [PATCH v3] r8169: remove "PHY reset until link up" log spam
Date: Fri,  2 Aug 2013 10:36:55 +0200
Message-ID: <1375432615-7901-1-git-send-email-lekensteyn@gmail.com>
Cc: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	nic_swsd@realtek.com, lekensteyn@gmail.com
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ea0-f177.google.com ([209.85.215.177]:51559 "EHLO
	mail-ea0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757888Ab3HBIhB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 2 Aug 2013 04:37:01 -0400
Received: by mail-ea0-f177.google.com with SMTP id f15so176820eak.22
        for <netdev@vger.kernel.org>; Fri, 02 Aug 2013 01:36:59 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This message was added in commit a7154cb8 (June 2004, [PATCH] r8169:
link handling and phy reset rework) and is printed every ten seconds
when no cable is connected and runtime power management is disabled.
(Before that commit, "Reset RTL8169s PHY" would be printed instead.)

Signed-off-by: Peter Wu <lekensteyn@gmail.com>
---
 drivers/net/ethernet/realtek/r8169.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/realtek/r8169.c b/drivers/net/ethernet/realtek/r8169.c
index 880015c..b5eb419 100644
--- a/drivers/net/ethernet/realtek/r8169.c
+++ b/drivers/net/ethernet/realtek/r8169.c
@@ -3689,7 +3689,7 @@ static void rtl_phy_work(struct rtl8169_private *tp)
 	if (tp->link_ok(ioaddr))
 		return;
 
-	netif_warn(tp, link, tp->dev, "PHY reset until link up\n");
+	netif_dbg(tp, link, tp->dev, "PHY reset until link up\n");
 
 	tp->phy_reset_enable(tp);
 
-- 
1.8.3.3
