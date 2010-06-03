From: Junchang Wang <junchangwang@gmail.com>
Subject: [Patch 1/2]r8169: remove rtl_rw_cpluscmd
Date: Thu, 3 Jun 2010 19:24:30 +0800
Message-ID: <20100603112428.GC24909@host-a-55.ustcsz.edu.cn>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: romieu@fr.zoreil.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-px0-f174.google.com ([209.85.212.174]:61304 "EHLO
	mail-px0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750970Ab0FCLYW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Jun 2010 07:24:22 -0400
Received: by pxi8 with SMTP id 8so410106pxi.19
        for <netdev@vger.kernel.org>; Thu, 03 Jun 2010 04:24:22 -0700 (PDT)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Some clean up work. Please correct me if any of this is wrong.


Writting "cmd" back without modification is redundant.
Secondly, because rtl_rw_cpluscmd is just encapsulation of
RTL_R16, remove rtl_rw_cpluscmd.

Signed-off-by: Junchang Wang <junchangwang@gmail.com>
---
 drivers/net/r8169.c |   13 ++-----------
 1 files changed, 2 insertions(+), 11 deletions(-)

diff --git a/drivers/net/r8169.c b/drivers/net/r8169.c
index 217e709..6a37813 100644
--- a/drivers/net/r8169.c
+++ b/drivers/net/r8169.c
@@ -3404,15 +3404,6 @@ static void rtl_set_rx_tx_desc_registers(struct rtl8169_private *tp,
 	RTL_W32(RxDescAddrLow, ((u64) tp->RxPhyAddr) & DMA_BIT_MASK(32));
 }
 
-static u16 rtl_rw_cpluscmd(void __iomem *ioaddr)
-{
-	u16 cmd;
-
-	cmd = RTL_R16(CPlusCmd);
-	RTL_W16(CPlusCmd, cmd);
-	return cmd;
-}
-
 static void rtl_set_rx_max_size(void __iomem *ioaddr, unsigned int rx_buf_sz)
 {
 	/* Low hurts. Let's disable the filtering. */
@@ -3471,7 +3462,7 @@ static void rtl_hw_start_8169(struct net_device *dev)
 	    (tp->mac_version == RTL_GIGA_MAC_VER_04))
 		rtl_set_rx_tx_config_registers(tp);
 
-	tp->cp_cmd |= rtl_rw_cpluscmd(ioaddr) | PCIMulRW;
+	tp->cp_cmd |= RTL_R16(CPlusCmd) | PCIMulRW;
 
 	if ((tp->mac_version == RTL_GIGA_MAC_VER_02) ||
 	    (tp->mac_version == RTL_GIGA_MAC_VER_03)) {
@@ -3906,7 +3897,7 @@ static void rtl_hw_start_8101(struct net_device *dev)
 
 	rtl_set_rx_max_size(ioaddr, tp->rx_buf_sz);
 
-	tp->cp_cmd |= rtl_rw_cpluscmd(ioaddr) | PCIMulRW;
+	tp->cp_cmd |= RTL_R16(CPlusCmd) | PCIMulRW;
 
 	RTL_W16(CPlusCmd, tp->cp_cmd);
-- 
