From: Ben Hutchings <ben@decadent.org.uk>
Subject: [PATCH net-next-2.6] 3c59x: Fix call to mdio_sync() with the wrong
 argument
Date: Fri, 23 Jul 2010 01:18:28 +0100
Message-ID: <1279844308.4883.365.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8BIT
Cc: netdev <netdev@vger.kernel.org>,
	Luca Falavigna <dktrkranz@debian.org>, 589989@bugs.debian.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:49526 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756167Ab0GWASg convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 22 Jul 2010 20:18:36 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

commit a095cfc40ec7ebe63e9532383c5b5c2a27b14075
"3c59x: Specify window explicitly for access to windowed registers"
changed the first parameter to mdio_sync(), from a pointer to the
register mapping, to a pointer to the vortex_private structure,
and changed all but one of the call sites.  Fix that last one.

Reported-by: Luca Falavigna <dktrkranz@debian.org>
Signed-off-by: Ben Hutchings <ben@decadent.org.uk>
---
 drivers/net/3c59x.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/3c59x.c b/drivers/net/3c59x.c
index 069a03f..b124283 100644
--- a/drivers/net/3c59x.c
+++ b/drivers/net/3c59x.c
@@ -1387,7 +1387,7 @@ static int __devinit vortex_probe1(struct device *gendev,
 		mii_preamble_required++;
 		if (vp->drv_flags & EXTRA_PREAMBLE)
 			mii_preamble_required++;
-		mdio_sync(ioaddr, 32);
+		mdio_sync(vp, 32);
 		mdio_read(dev, 24, MII_BMSR);
 		for (phy = 0; phy < 32 && phy_idx < 1; phy++) {
 			int mii_status, phyx;
-- 
1.7.1


