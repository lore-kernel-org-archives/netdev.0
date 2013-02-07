From: =?UTF-8?q?Rafa=C5=82=20Mi=C5=82ecki?= <zajec5@gmail.com>
Subject: [PATCH V2] bgmac: validate MAC addr
Date: Thu,  7 Feb 2013 11:14:38 +0100
Message-ID: <1360232078-21872-1-git-send-email-zajec5@gmail.com>
References: <1360143452-29183-1-git-send-email-zajec5@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Florian Fainelli <florian@openwrt.org>,
	=?UTF-8?q?Rafa=C5=82=20Mi=C5=82ecki?= <zajec5@gmail.com>
To: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f53.google.com ([74.125.83.53]:56640 "EHLO
	mail-ee0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751849Ab3BGKO7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Feb 2013 05:14:59 -0500
Received: by mail-ee0-f53.google.com with SMTP id e53so1290197eek.40
        for <netdev@vger.kernel.org>; Thu, 07 Feb 2013 02:14:57 -0800 (PST)
In-Reply-To: <1360143452-29183-1-git-send-email-zajec5@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Rafa=C5=82 Mi=C5=82ecki <zajec5@gmail.com>
---
V2: generate random addr
---
 drivers/net/ethernet/broadcom/bgmac.c |    6 ++++++
 1 file changed, 6 insertions(+)

diff --git a/drivers/net/ethernet/broadcom/bgmac.c b/drivers/net/ethern=
et/broadcom/bgmac.c
index d08a4af..f90d1dc 100644
--- a/drivers/net/ethernet/broadcom/bgmac.c
+++ b/drivers/net/ethernet/broadcom/bgmac.c
@@ -1318,6 +1318,12 @@ static int bgmac_probe(struct bcma_device *core)
 		return -ENOTSUPP;
 	}
=20
+	if (!is_valid_ether_addr(mac)) {
+		dev_err(&core->dev, "Invalid MAC addr: %pM\n", mac);
+		eth_random_addr(mac);
+		dev_warn(&core->dev, "Using random MAC: %pM\n", mac);
+	}
+
 	/* Allocation and references */
 	net_dev =3D alloc_etherdev(sizeof(*bgmac));
 	if (!net_dev)
--=20
1.7.10.4
