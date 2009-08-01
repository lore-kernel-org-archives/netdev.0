From: Julia Lawall <julia@diku.dk>
Subject: [PATCH 5/5] drivers/net: Use DIV_ROUND_CLOSEST
Date: Sat, 1 Aug 2009 21:51:06 +0200 (CEST)
Message-ID: <Pine.LNX.4.64.0908012150340.25693@ask.diku.dk>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
To: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	kernel-janitors@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1752328AbZHATvL@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Julia Lawall <julia@diku.dk>

The kernel.h macro DIV_ROUND_CLOSEST performs the computation (x + d/2)/d
but is perhaps more readable.

The semantic patch that makes this change is as follows:
(http://www.emn.fr/x-info/coccinelle/)

// <smpl>
@haskernel@
@@

#include <linux/kernel.h>

@depends on haskernel@
expression x,__divisor;
@@

- (((x) + ((__divisor) / 2)) / (__divisor))
+ DIV_ROUND_CLOSEST(x,__divisor)
// </smpl>

Signed-off-by: Julia Lawall <julia@diku.dk>

---
 drivers/net/b44.c                   |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/drivers/net/b44.c b/drivers/net/b44.c
index 1f7f015..07c92f3 100644
--- a/drivers/net/b44.c
+++ b/drivers/net/b44.c
@@ -1297,7 +1297,8 @@ static void b44_chip_reset(struct b44 *bp, int reset_kind)
 	switch (sdev->bus->bustype) {
 	case SSB_BUSTYPE_SSB:
 		bw32(bp, B44_MDIO_CTRL, (MDIO_CTRL_PREAMBLE |
-		     (((ssb_clockspeed(sdev->bus) + (B44_MDC_RATIO / 2)) / B44_MDC_RATIO)
+		     (DIV_ROUND_CLOSEST(ssb_clockspeed(sdev->bus),
+					B44_MDC_RATIO)
 		     & MDIO_CTRL_MAXF_MASK)));
 		break;
 	case SSB_BUSTYPE_PCI:
