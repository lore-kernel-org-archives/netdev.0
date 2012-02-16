From: "Shimoda, Yoshihiro" <yoshihiro.shimoda.uh@renesas.com>
Subject: [PATCH net-next 2/5] net: sh_eth: change the condition of
 initialization
Date: Thu, 16 Feb 2012 12:54:56 +0900
Message-ID: <4F3C7E10.3060905@renesas.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Nobuhiro Iwamatsu <nobuhiro.iwamatsu.yj@renesas.com>
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relmlor4.renesas.com ([210.160.252.174]:57939 "EHLO
	relmlor4.renesas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750995Ab2BPDy6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Feb 2012 22:54:58 -0500
Received: from relmlir2.idc.renesas.com ([10.200.68.152])
 by relmlor4.idc.renesas.com ( SJSMS)
 with ESMTP id <0LZG00M5DW7K0E40@relmlor4.idc.renesas.com> for
 netdev@vger.kernel.org; Thu, 16 Feb 2012 12:54:56 +0900 (JST)
Received: from relmlac2.idc.renesas.com ([10.200.69.22])
 by relmlir2.idc.renesas.com ( SJSMS)
 with ESMTP id <0LZG00905W7K3S10@relmlir2.idc.renesas.com> for
 netdev@vger.kernel.org; Thu, 16 Feb 2012 12:54:56 +0900 (JST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The SH7757 has 2 Fast Ethernet and 2 Gigabit Ethernet, and the first
Gigabit channel needs the initialization. So, this patch adds the
parameter of "needs_init", and if the sh_eth_plat_data is set it
to 1, the driver will initialize the channel.

Signed-off-by: Yoshihiro Shimoda <yoshihiro.shimoda.uh@renesas.com>
---
 drivers/net/ethernet/renesas/sh_eth.c |    4 ++--
 include/linux/sh_eth.h                |    1 +
 2 files changed, 3 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/renesas/sh_eth.c b/drivers/net/ethernet/renesas/sh_eth.c
index 8f53b5a..5a5afbc 100644
--- a/drivers/net/ethernet/renesas/sh_eth.c
+++ b/drivers/net/ethernet/renesas/sh_eth.c
@@ -1859,8 +1859,8 @@ static int sh_eth_drv_probe(struct platform_device *pdev)
 	/* read and set MAC address */
 	read_mac_address(ndev, pd->mac_addr);

-	/* First device only init */
-	if (!devno) {
+	/* initialize first or needed device */
+	if (!devno || pd->needs_init) {
 		if (mdp->cd->tsu) {
 			struct resource *rtsu;
 			rtsu = platform_get_resource(pdev, IORESOURCE_MEM, 1);
diff --git a/include/linux/sh_eth.h b/include/linux/sh_eth.h
index 2076acf..b17d765 100644
--- a/include/linux/sh_eth.h
+++ b/include/linux/sh_eth.h
@@ -20,6 +20,7 @@ struct sh_eth_plat_data {
 	unsigned char mac_addr[6];
 	unsigned no_ether_link:1;
 	unsigned ether_link_active_low:1;
+	unsigned needs_init:1;
 };

 #endif
-- 
1.7.1
