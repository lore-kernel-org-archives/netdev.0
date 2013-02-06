From: =?UTF-8?q?Rafa=C5=82=20Mi=C5=82ecki?= <zajec5@gmail.com>
Subject: [PATCH] bgmac: validate MAC addr
Date: Wed,  6 Feb 2013 10:37:32 +0100
Message-ID: <1360143452-29183-1-git-send-email-zajec5@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: =?UTF-8?q?Rafa=C5=82=20Mi=C5=82ecki?= <zajec5@gmail.com>
To: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ea0-f171.google.com ([209.85.215.171]:46573 "EHLO
	mail-ea0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751961Ab3BFJhm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Feb 2013 04:37:42 -0500
Received: by mail-ea0-f171.google.com with SMTP id c13so473361eaa.30
        for <netdev@vger.kernel.org>; Wed, 06 Feb 2013 01:37:41 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Signed-off-by: Rafa=C5=82 Mi=C5=82ecki <zajec5@gmail.com>
---
 drivers/net/ethernet/broadcom/bgmac.c |    5 +++++
 1 file changed, 5 insertions(+)

diff --git a/drivers/net/ethernet/broadcom/bgmac.c b/drivers/net/ethern=
et/broadcom/bgmac.c
index af149a3..9f95089 100644
--- a/drivers/net/ethernet/broadcom/bgmac.c
+++ b/drivers/net/ethernet/broadcom/bgmac.c
@@ -1290,6 +1290,11 @@ static int bgmac_probe(struct bcma_device *core)
 		return -ENOTSUPP;
 	}
=20
+	if (!is_valid_ether_addr(mac)) {
+		dev_err(&core->dev, "Invalid MAC addr: %pM\n", mac);
+		return -EADDRNOTAVAIL;
+	}
+
 	/* Allocation and references */
 	net_dev =3D alloc_etherdev(sizeof(*bgmac));
 	if (!net_dev)
--=20
1.7.10.4
