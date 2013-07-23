From: Peter Wu <lekensteyn@gmail.com>
Subject: r8169: remove "PHY reset until link up" log spam
Date: Tue, 23 Jul 2013 11:55:57 +0200
Message-ID: <4961229.bXDGvH0dpz@al>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	nic_swsd@realtek.com
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f54.google.com ([209.85.214.54]:34338 "EHLO
	mail-bk0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756075Ab3GWJ4C (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Jul 2013 05:56:02 -0400
Received: by mail-bk0-f54.google.com with SMTP id it16so2915164bkc.13
        for <netdev@vger.kernel.org>; Tue, 23 Jul 2013 02:56:01 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This message was added in commit a7154cb8 (June 2004) and is printed
every ten seconds when no cable is connected.

Signed-off-by: Peter Wu <lekensteyn@gmail.com>
---
Using ethtool to silence *all* link warnings is still a manual
operation, in my opinion not acceptable so let's remove this message.

The r8169 constantly resets the device when no link is connected,
contrary the r8168 vendor driver which only resets the link when some
PCI config fields have been modified. As the current reset logic in r8168
seems to work for broken device (which I do not have have and therefore
cannot test), I did not attempt to "clean this up".
---
 drivers/net/ethernet/realtek/r8169.c | 2 --
 1 file changed, 2 deletions(-)

diff --git a/drivers/net/ethernet/realtek/r8169.c b/drivers/net/ethernet/realtek/r8169.c
index 880015c..63f04af 100644
--- a/drivers/net/ethernet/realtek/r8169.c
+++ b/drivers/net/ethernet/realtek/r8169.c
@@ -3689,8 +3689,6 @@ static void rtl_phy_work(struct rtl8169_private *tp)
 	if (tp->link_ok(ioaddr))
 		return;
 
-	netif_warn(tp, link, tp->dev, "PHY reset until link up\n");
-
 	tp->phy_reset_enable(tp);
 
 out_mod_timer:
-- 
1.8.3.3
