From: =?UTF-8?q?Rafa=C5=82=20Mi=C5=82ecki?= <zajec5@gmail.com>
Subject: [PATCH] bgmac: start/stop PHY on netdev open/stop
Date: Tue, 10 Dec 2013 17:19:39 +0100
Message-ID: <1386692379-16648-1-git-send-email-zajec5@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Hauke Mehrtens <hauke@hauke-m.de>,
	=?UTF-8?q?Rafa=C5=82=20Mi=C5=82ecki?= <zajec5@gmail.com>
To: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f44.google.com ([74.125.83.44]:38896 "EHLO
	mail-ee0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753016Ab3LJQTx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Dec 2013 11:19:53 -0500
Received: by mail-ee0-f44.google.com with SMTP id b57so2349991eek.3
        for <netdev@vger.kernel.org>; Tue, 10 Dec 2013 08:19:52 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I've realized that I need to call ethtool command to get Ethernet
working after booting. Ex call: ethtool -s eth0 autoneg on
It was fixing Ethernet even if auto-negotiation was already on.

Adding calls to phy_start and phy_stop look like a real solution.

Signed-off-by: Rafa=C5=82 Mi=C5=82ecki <zajec5@gmail.com>
---
 drivers/net/ethernet/broadcom/bgmac.c |    4 ++++
 1 file changed, 4 insertions(+)

diff --git a/drivers/net/ethernet/broadcom/bgmac.c b/drivers/net/ethern=
et/broadcom/bgmac.c
index db71d75..055204e 100644
--- a/drivers/net/ethernet/broadcom/bgmac.c
+++ b/drivers/net/ethernet/broadcom/bgmac.c
@@ -1139,6 +1139,8 @@ static int bgmac_open(struct net_device *net_dev)
 	}
 	napi_enable(&bgmac->napi);
=20
+	phy_start(bgmac->phy_dev);
+
 	netif_carrier_on(net_dev);
=20
 err_out:
@@ -1151,6 +1153,8 @@ static int bgmac_stop(struct net_device *net_dev)
=20
 	netif_carrier_off(net_dev);
=20
+	phy_stop(bgmac->phy_dev);
+
 	napi_disable(&bgmac->napi);
 	bgmac_chip_intrs_off(bgmac);
 	free_irq(bgmac->core->irq, net_dev);
--=20
1.7.10.4
