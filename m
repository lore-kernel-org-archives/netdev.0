From: Nobuhiro Iwamatsu <nobuhiro.iwamatsu.yj@renesas.com>
Subject: [PATCH v3 8/9] net: sh-eth: Remove ifdef for sh_eth_select_mii
Date: Tue,  7 May 2013 14:17:54 +0900
Message-ID: <1367903875-32606-8-git-send-email-nobuhiro.iwamatsu.yj@renesas.com>
References: <1367903875-32606-1-git-send-email-nobuhiro.iwamatsu.yj@renesas.com>
Cc: yoshihiro.shimoda.uh@renesas.com,
	sergei.shtylyov@cogentembedded.com,
	Nobuhiro Iwamatsu <nobuhiro.iwamatsu.yj@renesas.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f180.google.com ([209.85.192.180]:65227 "EHLO
	mail-pd0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751650Ab3EGFS3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 May 2013 01:18:29 -0400
Received: by mail-pd0-f180.google.com with SMTP id t10so138658pdi.11
        for <netdev@vger.kernel.org>; Mon, 06 May 2013 22:18:29 -0700 (PDT)
In-Reply-To: <1367903875-32606-1-git-send-email-nobuhiro.iwamatsu.yj@renesas.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Nobuhiro Iwamatsu <nobuhiro.iwamatsu.yj@renesas.com>
---
V3:
  Add __maybe_unused to sh_eth_select_mii().
V2:
  no change.
 drivers/net/ethernet/renesas/sh_eth.c |    6 +-----
 1 file changed, 1 insertion(+), 5 deletions(-)

diff --git a/drivers/net/ethernet/renesas/sh_eth.c b/drivers/net/ethernet/renesas/sh_eth.c
index 880f0ca..664a236 100644
--- a/drivers/net/ethernet/renesas/sh_eth.c
+++ b/drivers/net/ethernet/renesas/sh_eth.c
@@ -313,10 +313,7 @@ static const u16 sh_eth_offset_fast_sh3_sh2[SH_ETH_MAX_REGISTER_OFFSET] = {
 	[TSU_ADRL31]	= 0x01fc,
 };
 
-#if defined(CONFIG_CPU_SUBTYPE_SH7734) || \
-	defined(CONFIG_CPU_SUBTYPE_SH7763) || \
-	defined(CONFIG_ARCH_R8A7740)
-static void sh_eth_select_mii(struct net_device *ndev)
+static void __maybe_unused sh_eth_select_mii(struct net_device *ndev)
 {
 	u32 value = 0x0;
 	struct sh_eth_private *mdp = netdev_priv(ndev);
@@ -339,7 +336,6 @@ static void sh_eth_select_mii(struct net_device *ndev)
 
 	sh_eth_write(ndev, value, RMII_MII);
 }
-#endif
 
 static void sh_eth_set_duplex(struct net_device *ndev)
 {
-- 
1.7.10.4
