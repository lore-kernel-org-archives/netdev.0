From: Peter Wu <lekensteyn@gmail.com>
Subject: [PATCH] r8169,sis190: remove unnecessary length check
Date: Sat, 17 Aug 2013 01:07:53 +0200
Message-ID: <1376694473-8517-1-git-send-email-lekensteyn@gmail.com>
Cc: lekensteyn@gmail.com, netdev@vger.kernel.org
To: Ben Hutchings <bhutchings@solarflare.com>,
	Francois Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f48.google.com ([74.125.83.48]:48600 "EHLO
	mail-ee0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754204Ab3HQAAa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 Aug 2013 20:00:30 -0400
Received: by mail-ee0-f48.google.com with SMTP id l10so1165754eei.35
        for <netdev@vger.kernel.org>; Fri, 16 Aug 2013 17:00:28 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The ethtool core will lower the requested length to the one returned by
get_regs_len, therefore no additional check is needed in the get_regs
function.

Reported-by: Ben Hutchings <bhutchings@solarflare.com>
Signed-off-by: Peter Wu <lekensteyn@gmail.com>
---
Hi,

This was observed by Ben[1] while reviewing my other r8169 register dump
patch. I have combined the r8169 and sis190 patches since they were
trivial and both maintained by Francois. Let me know if you prefer to
split this trivial patch up.

Regards,
Peter

 [1]: http://www.spinics.net/lists/netdev/msg246690.html
---
 drivers/net/ethernet/realtek/r8169.c | 3 ---
 drivers/net/ethernet/sis/sis190.c    | 3 ---
 2 files changed, 6 deletions(-)

diff --git a/drivers/net/ethernet/realtek/r8169.c b/drivers/net/ethernet/realtek/r8169.c
index b5eb419..93ee49d 100644
--- a/drivers/net/ethernet/realtek/r8169.c
+++ b/drivers/net/ethernet/realtek/r8169.c
@@ -1898,9 +1898,6 @@ static void rtl8169_get_regs(struct net_device *dev, struct ethtool_regs *regs,
 {
 	struct rtl8169_private *tp = netdev_priv(dev);
 
-	if (regs->len > R8169_REGS_SIZE)
-		regs->len = R8169_REGS_SIZE;
-
 	rtl_lock_work(tp);
 	memcpy_fromio(p, tp->mmio_addr, regs->len);
 	rtl_unlock_work(tp);
diff --git a/drivers/net/ethernet/sis/sis190.c b/drivers/net/ethernet/sis/sis190.c
index 02df089..ee18e6f 100644
--- a/drivers/net/ethernet/sis/sis190.c
+++ b/drivers/net/ethernet/sis/sis190.c
@@ -1770,9 +1770,6 @@ static void sis190_get_regs(struct net_device *dev, struct ethtool_regs *regs,
 	struct sis190_private *tp = netdev_priv(dev);
 	unsigned long flags;
 
-	if (regs->len > SIS190_REGS_SIZE)
-		regs->len = SIS190_REGS_SIZE;
-
 	spin_lock_irqsave(&tp->lock, flags);
 	memcpy_fromio(p, tp->mmio_addr, regs->len);
 	spin_unlock_irqrestore(&tp->lock, flags);
-- 
1.8.3.4
