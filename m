From: "Sebastian =?ISO-8859-1?Q?P=F6hn?=" <sebastian.belden@googlemail.com>
Subject: [PATCH] gianfar: fix bug caused by
 87c288c6e9aa31720b72e2bc2d665e24e1653c3e
Date: Tue, 26 Jul 2011 12:03:13 +0200
Message-ID: <1311674593.17190.7.camel@DENEC1DT0191>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
To: Linux Netdev <netdev@vger.kernel.org>, jpirko@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ey0-f171.google.com ([209.85.215.171]:33414 "EHLO
	mail-ey0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752627Ab1GZKDS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Jul 2011 06:03:18 -0400
Received: by eye22 with SMTP id 22so381046eye.2
        for <netdev@vger.kernel.org>; Tue, 26 Jul 2011 03:03:17 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

commit 87c288c6e9aa31720b72e2bc2d665e24e1653c3e "gianfar: do vlan cleanup" has two issues:
# permutation of rx and tx flags
# enabling vlan tag insertion by default (this leads to unusable connections on some configurations)

If VLAN insertion is requested (via ethtool) it will be set at an other point ...

Signed-off-by: Sebastian Poehn <sebastian.poehn@belden.com>
---

 drivers/net/gianfar.c |    6 +-----
 1 files changed, 1 insertions(+), 5 deletions(-)

diff --git a/drivers/net/gianfar.c b/drivers/net/gianfar.c
index 835cd25..2659daa 100644
--- a/drivers/net/gianfar.c
+++ b/drivers/net/gianfar.c
@@ -388,12 +388,8 @@ static void gfar_init_mac(struct net_device *ndev)
 	if (priv->hwts_rx_en)
 		rctrl |= RCTRL_PRSDEP_INIT | RCTRL_TS_ENABLE;
 
-	/* keep vlan related bits if it's enabled */
-	if (ndev->features & NETIF_F_HW_VLAN_TX)
-		rctrl |= RCTRL_VLEX | RCTRL_PRSDEP_INIT;
-
 	if (ndev->features & NETIF_F_HW_VLAN_RX)
-		tctrl |= TCTRL_VLINS;
+		rctrl |= RCTRL_VLEX | RCTRL_PRSDEP_INIT;
 
 	/* Init rctrl based on our settings */
 	gfar_write(&regs->rctrl, rctrl);


