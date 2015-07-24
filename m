From: Andy Shevchenko <andriy.shevchenko@linux.intel.com>
Subject: [PATCH v1 4/6] net/macb: suppress compiler warnings
Date: Fri, 24 Jul 2015 21:24:02 +0300
Message-ID: <1437762244-2678-5-git-send-email-andriy.shevchenko@linux.intel.com>
References: <1437762244-2678-1-git-send-email-andriy.shevchenko@linux.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Andy Shevchenko <andriy.shevchenko@linux.intel.com>
To: Cyrille Pitchen <cyrille.pitchen@atmel.com>,
	Nicolas Ferre <nicolas.ferre@atmel.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:45091 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752880AbbGXSYI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 24 Jul 2015 14:24:08 -0400
In-Reply-To: <1437762244-2678-1-git-send-email-andriy.shevchenko@linux.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch fixes the following warnings:
drivers/net/ethernet/cadence/macb.c: In function =E2=80=98macb_handle_l=
ink_change=E2=80=99:
drivers/net/ethernet/cadence/macb.c:266: warning: comparison between si=
gned and unsigned
drivers/net/ethernet/cadence/macb.c:267: warning: comparison between si=
gned and unsigned
drivers/net/ethernet/cadence/macb.c:291: warning: comparison between si=
gned and unsigned
drivers/net/ethernet/cadence/macb.c: In function =E2=80=98gem_update_st=
ats=E2=80=99:
drivers/net/ethernet/cadence/macb.c:1908: warning: comparison between s=
igned and unsigned
drivers/net/ethernet/cadence/macb.c: In function =E2=80=98gem_get_ethto=
ol_strings=E2=80=99:
drivers/net/ethernet/cadence/macb.c:1988: warning: comparison between s=
igned and unsigned

Signed-off-by: Andy Shevchenko <andriy.shevchenko@linux.intel.com>
---
 drivers/net/ethernet/cadence/macb.c | 5 ++---
 drivers/net/ethernet/cadence/macb.h | 6 +++---
 2 files changed, 5 insertions(+), 6 deletions(-)

diff --git a/drivers/net/ethernet/cadence/macb.c b/drivers/net/ethernet=
/cadence/macb.c
index 367fc9d..13d7e96 100644
--- a/drivers/net/ethernet/cadence/macb.c
+++ b/drivers/net/ethernet/cadence/macb.c
@@ -303,7 +303,6 @@ static void macb_handle_link_change(struct net_devi=
ce *dev)
 	struct macb *bp =3D netdev_priv(dev);
 	struct phy_device *phydev =3D bp->phy_dev;
 	unsigned long flags;
-
 	int status_change =3D 0;
=20
 	spin_lock_irqsave(&bp->lock, flags);
@@ -1936,7 +1935,7 @@ static int macb_change_mtu(struct net_device *dev=
, int new_mtu)
=20
 static void gem_update_stats(struct macb *bp)
 {
-	int i;
+	unsigned int i;
 	u32 *p =3D &bp->hw_stats.gem.tx_octets_31_0;
=20
 	for (i =3D 0; i < GEM_STATS_LEN; ++i, ++p) {
@@ -2015,7 +2014,7 @@ static int gem_get_sset_count(struct net_device *=
dev, int sset)
=20
 static void gem_get_ethtool_strings(struct net_device *dev, u32 sset, =
u8 *p)
 {
-	int i;
+	unsigned int i;
=20
 	switch (sset) {
 	case ETH_SS_STATS:
diff --git a/drivers/net/ethernet/cadence/macb.h b/drivers/net/ethernet=
/cadence/macb.h
index f245340..2aa102e 100644
--- a/drivers/net/ethernet/cadence/macb.h
+++ b/drivers/net/ethernet/cadence/macb.h
@@ -816,9 +816,9 @@ struct macb {
=20
 	struct mii_bus		*mii_bus;
 	struct phy_device	*phy_dev;
-	unsigned int 		link;
-	unsigned int 		speed;
-	unsigned int 		duplex;
+	int 			link;
+	int 			speed;
+	int 			duplex;
=20
 	u32			caps;
 	unsigned int		dma_burst_length;
--=20
2.4.6
