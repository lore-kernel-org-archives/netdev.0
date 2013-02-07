From: =?UTF-8?q?Rafa=C5=82=20Mi=C5=82ecki?= <zajec5@gmail.com>
Subject: [PATCH V2] bgmac: fix "cmdcfg" calls for promisc and loopback modes
Date: Thu,  7 Feb 2013 16:40:38 +0100
Message-ID: <1360251638-20925-1-git-send-email-zajec5@gmail.com>
References: <1360232591-25789-1-git-send-email-zajec5@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Nathan Hintz <nlhintz@hotmail.com>,
	=?UTF-8?q?Rafa=C5=82=20Mi=C5=82ecki?= <zajec5@gmail.com>
To: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f172.google.com ([209.85.212.172]:60769 "EHLO
	mail-wi0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751057Ab3BGPk5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Feb 2013 10:40:57 -0500
Received: by mail-wi0-f172.google.com with SMTP id ez12so7064398wid.17
        for <netdev@vger.kernel.org>; Thu, 07 Feb 2013 07:40:56 -0800 (PST)
In-Reply-To: <1360232591-25789-1-git-send-email-zajec5@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The last (bool) parameter in bgmac_cmdcfg_maskset says if the write
should be made, even if value didn't change. Currently driver doesn't
match the specs about (not) forcing some changes. This makes it follow
them.

Reported-by: Nathan Hintz <nlhintz@hotmail.com>
Signed-off-by: Rafa=C5=82 Mi=C5=82ecki <zajec5@gmail.com>
---
V2: commit message
---
 drivers/net/ethernet/broadcom/bgmac.c |    8 ++++----
 1 file changed, 4 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bgmac.c b/drivers/net/ethern=
et/broadcom/bgmac.c
index f90d1dc..8cf5e39 100644
--- a/drivers/net/ethernet/broadcom/bgmac.c
+++ b/drivers/net/ethernet/broadcom/bgmac.c
@@ -776,9 +776,9 @@ static void bgmac_set_rx_mode(struct net_device *ne=
t_dev)
 	struct bgmac *bgmac =3D netdev_priv(net_dev);
=20
 	if (net_dev->flags & IFF_PROMISC)
-		bgmac_cmdcfg_maskset(bgmac, ~0, BGMAC_CMDCFG_PROM, false);
+		bgmac_cmdcfg_maskset(bgmac, ~0, BGMAC_CMDCFG_PROM, true);
 	else
-		bgmac_cmdcfg_maskset(bgmac, ~BGMAC_CMDCFG_PROM, 0, false);
+		bgmac_cmdcfg_maskset(bgmac, ~BGMAC_CMDCFG_PROM, 0, true);
 }
=20
 #if 0 /* We don't use that regs yet */
@@ -1039,9 +1039,9 @@ static void bgmac_chip_init(struct bgmac *bgmac, =
bool full_init)
 	bgmac_write_mac_address(bgmac, bgmac->net_dev->dev_addr);
=20
 	if (bgmac->loopback)
-		bgmac_cmdcfg_maskset(bgmac, ~0, BGMAC_CMDCFG_ML, true);
+		bgmac_cmdcfg_maskset(bgmac, ~0, BGMAC_CMDCFG_ML, false);
 	else
-		bgmac_cmdcfg_maskset(bgmac, ~BGMAC_CMDCFG_ML, 0, true);
+		bgmac_cmdcfg_maskset(bgmac, ~BGMAC_CMDCFG_ML, 0, false);
=20
 	bgmac_write(bgmac, BGMAC_RXMAX_LENGTH, 32 + ETHER_MAX_LEN);
=20
--=20
1.7.10.4
