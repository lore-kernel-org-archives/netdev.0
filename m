From: =?UTF-8?q?Rafa=C5=82=20Mi=C5=82ecki?= <zajec5@gmail.com>
Subject: [PATCH 4.6 fix] bgmac: reset & enable Ethernet core before using it
Date: Tue, 12 Apr 2016 13:30:45 +0200
Message-ID: <1460460645-10016-1-git-send-email-zajec5@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Hauke Mehrtens <hauke@hauke-m.de>,
	=?UTF-8?q?Rafa=C5=82=20Mi=C5=82ecki?= <zajec5@gmail.com>,
	Felix Fietkau <nbd@openwrt.org>
To: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f47.google.com ([209.85.215.47]:36037 "EHLO
	mail-lf0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932393AbcDLLbM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Apr 2016 07:31:12 -0400
Received: by mail-lf0-f47.google.com with SMTP id g184so20638475lfb.3
        for <netdev@vger.kernel.org>; Tue, 12 Apr 2016 04:31:11 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This fixes Ethernet on D-Link DIR-885L with BCM47094 SoC. Felix reporte=
d
similar fix was needed for his BCM4709 device (Buffalo WXR-1900DHP?).
I tested this for regressions on BCM4706, BCM4708A0 and BCM47081A0.

Cc: Felix Fietkau <nbd@openwrt.org>
Signed-off-by: Rafa=C5=82 Mi=C5=82ecki <zajec5@gmail.com>
---
 drivers/net/ethernet/broadcom/bgmac.c | 5 +++++
 1 file changed, 5 insertions(+)

diff --git a/drivers/net/ethernet/broadcom/bgmac.c b/drivers/net/ethern=
et/broadcom/bgmac.c
index 99b30a9..38db2e4 100644
--- a/drivers/net/ethernet/broadcom/bgmac.c
+++ b/drivers/net/ethernet/broadcom/bgmac.c
@@ -1572,6 +1572,11 @@ static int bgmac_probe(struct bcma_device *core)
 		dev_warn(&core->dev, "Using random MAC: %pM\n", mac);
 	}
=20
+	/* This (reset &) enable is not preset in specs or reference driver b=
ut
+	 * Broadcom does it in arch PCI code when enabling fake PCI device.
+	 */
+	bcma_core_enable(core, 0);
+
 	/* Allocation and references */
 	net_dev =3D alloc_etherdev(sizeof(*bgmac));
 	if (!net_dev)
--=20
1.8.4.5
