From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
	<yoshfuji@linux-ipv6.org>
Subject: [PATCH] ARM/ETHER3: Handle multicast frames.
Date: Tue, 17 Jul 2007 13:45:43 +0900 (JST)
Message-ID: <20070717.134543.14986183.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: jgarzik@pobox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from yue.linux-ipv6.org ([203.178.140.15]:48109 "EHLO
	yue.st-paulia.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753090AbXGQEo7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Jul 2007 00:44:59 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>

--
diff --git a/drivers/net/arm/ether3.c b/drivers/net/arm/ether3.c
index da71350..a7cac69 100644
--- a/drivers/net/arm/ether3.c
+++ b/drivers/net/arm/ether3.c
@@ -464,7 +464,7 @@ static void ether3_setmulticastlist(struct net_device *dev)
 	if (dev->flags & IFF_PROMISC) {
 		/* promiscuous mode */
 		priv(dev)->regs.config1 |= CFG1_RECVPROMISC;
-	} else if (dev->flags & IFF_ALLMULTI) {
+	} else if (dev->flags & IFF_ALLMULTI || dev->mc_count) {
 		priv(dev)->regs.config1 |= CFG1_RECVSPECBRMULTI;
 	} else
 		priv(dev)->regs.config1 |= CFG1_RECVSPECBROAD;

-- 
YOSHIFUJI Hideaki @ USAGI Project  <yoshfuji@linux-ipv6.org>
GPG-FP  : 9022 65EB 1ECF 3AD1 0BDF  80D8 4807 F894 E062 0EEA
