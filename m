From: =?UTF-8?q?Rafa=C5=82=20Mi=C5=82ecki?= <zajec5@gmail.com>
Subject: [PATCH 4.6 fix] bgmac: fix MAC soft-reset bit for corerev > 4
Date: Tue, 12 Apr 2016 18:27:29 +0200
Message-ID: <1460478449-22561-1-git-send-email-zajec5@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Hauke Mehrtens <hauke@hauke-m.de>, Felix Fietkau <nbd@openwrt.org>,
	=?UTF-8?q?Rafa=C5=82=20Mi=C5=82ecki?= <zajec5@gmail.com>
To: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f42.google.com ([209.85.215.42]:33563 "EHLO
	mail-lf0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756803AbcDLQ1o (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Apr 2016 12:27:44 -0400
Received: by mail-lf0-f42.google.com with SMTP id e190so33075906lfe.0
        for <netdev@vger.kernel.org>; Tue, 12 Apr 2016 09:27:43 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Felix Fietkau <nbd@openwrt.org>

Only core revisions older than 4 use BGMAC_CMDCFG_SR_REV0. This mainly
fixes support for BCM4708A0KF SoCs with Ethernet core rev 5 (it means
only some devices as most of BCM4708A0KF-s got core rev 4).
This was tested for regressions on BCM47094 which doesn't seem to care
which bit gets used.

Signed-off-by: Felix Fietkau <nbd@openwrt.org>
Signed-off-by: Rafa=C5=82 Mi=C5=82ecki <zajec5@gmail.com>
---
If it's OK for everyone, I suggest taking this patch into net.git repo.
It obviously can't regress old devices and was well tested on new ones
by OpenWrt users.
---
 drivers/net/ethernet/broadcom/bgmac.h | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bgmac.h b/drivers/net/ethern=
et/broadcom/bgmac.h
index 4fbb093..9a03c14 100644
--- a/drivers/net/ethernet/broadcom/bgmac.h
+++ b/drivers/net/ethernet/broadcom/bgmac.h
@@ -199,9 +199,9 @@
 #define  BGMAC_CMDCFG_TAI			0x00000200
 #define  BGMAC_CMDCFG_HD			0x00000400	/* Set if in half duplex mode */
 #define  BGMAC_CMDCFG_HD_SHIFT			10
-#define  BGMAC_CMDCFG_SR_REV0			0x00000800	/* Set to reset mode, for o=
ther revs */
-#define  BGMAC_CMDCFG_SR_REV4			0x00002000	/* Set to reset mode, only =
for core rev 4 */
-#define  BGMAC_CMDCFG_SR(rev)  ((rev =3D=3D 4) ? BGMAC_CMDCFG_SR_REV4 =
: BGMAC_CMDCFG_SR_REV0)
+#define  BGMAC_CMDCFG_SR_REV0			0x00000800	/* Set to reset mode, for c=
ore rev 0-3 */
+#define  BGMAC_CMDCFG_SR_REV4			0x00002000	/* Set to reset mode, for c=
ore rev >=3D 4 */
+#define  BGMAC_CMDCFG_SR(rev)  ((rev >=3D 4) ? BGMAC_CMDCFG_SR_REV4 : =
BGMAC_CMDCFG_SR_REV0)
 #define  BGMAC_CMDCFG_ML			0x00008000	/* Set to activate mac loopback =
mode */
 #define  BGMAC_CMDCFG_AE			0x00400000
 #define  BGMAC_CMDCFG_CFE			0x00800000
--=20
1.8.4.5
