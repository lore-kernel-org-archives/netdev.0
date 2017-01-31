From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next] net: dsa: bcm_sf2: Fix build module
Date: Mon, 30 Jan 2017 19:17:16 -0800
Message-ID: <20170131031716.31304-1-f.fainelli@gmail.com>
Cc: davem@davemloft.net, andrew@lunn.ch,
        vivien.didelot@savoirfairelinux.com,
        Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f194.google.com ([209.85.192.194]:35725 "EHLO
        mail-pf0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750925AbdAaDSL (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 30 Jan 2017 22:18:11 -0500
Received: by mail-pf0-f194.google.com with SMTP id f144so25386256pfa.2
        for <netdev@vger.kernel.org>; Mon, 30 Jan 2017 19:18:03 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Commit 7318166cacad ("net: dsa: bcm_sf2: Add support for
ethtool::rxnfc") added a new object to build: bcm_sf2_cfp.o, but in
doing so, we essentially just built this object and no longer bcm_sf2.o.

Fix this by creating a module named bcm-sf2.ko which links in bcm_sf2.o
and bcm_sf2_cfp.o.

Fixes: 7318166cacad ("net: dsa: bcm_sf2: Add support for ethtool::rxnfc")
Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 drivers/net/dsa/Makefile | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/dsa/Makefile b/drivers/net/dsa/Makefile
index da9893478e21..a3c941632217 100644
--- a/drivers/net/dsa/Makefile
+++ b/drivers/net/dsa/Makefile
@@ -1,6 +1,6 @@
 obj-$(CONFIG_NET_DSA_MV88E6060) += mv88e6060.o
-obj-$(CONFIG_NET_DSA_BCM_SF2)	+= bcm_sf2.o
-bcm_sf2-objs			+= bcm_sf2_cfp.o
+obj-$(CONFIG_NET_DSA_BCM_SF2)	+= bcm-sf2.o
+bcm-sf2-objs			:= bcm_sf2.o bcm_sf2_cfp.o
 obj-$(CONFIG_NET_DSA_QCA8K)	+= qca8k.o
 
 obj-y				+= b53/
-- 
2.9.3
