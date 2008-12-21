From: Julia Lawall <julia@diku.dk>
Subject: [PATCH 4/13] drivers/net/au1000_eth.c: Remove redundant test
Date: Sun, 21 Dec 2008 16:37:36 +0100 (CET)
Message-ID: <Pine.LNX.4.64.0812211637180.9555@pc-004.diku.dk>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
To: manuel.lauss@gmail.com, jgarzik@pobox.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, kernel-janitors@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mgw1.diku.dk ([130.225.96.91]:56112 "EHLO mgw1.diku.dk"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752441AbYLUPhk (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 21 Dec 2008 10:37:40 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Julia Lawall <julia@diku.dk>

phydev is checked to be not NULL a few lines above.

A simplified version of the semantic patch that makes this change is as
follows: (http://www.emn.fr/x-info/coccinelle/)

// <smpl>
@r exists@
local idexpression x;
expression E;
position p1,p2;
@@

if (x@p1 == NULL || ...) { ... when forall
   return ...; }
... when != \(x=E\|x--\|x++\|--x\|++x\|x-=E\|x+=E\|x|=E\|x&=E\|&x\)
(
x@p2 == NULL
|
x@p2 != NULL
)

// another path to the test that is not through p1?
@s exists@
local idexpression r.x;
position r.p1,r.p2;
@@

... when != x@p1
(
x@p2 == NULL
|
x@p2 != NULL
)

@fix depends on !s@
position r.p1,r.p2;
expression x,E;
statement S1,S2;
@@

(
- if ((x@p2 != NULL) || ...)
  S1
|
- if ((x@p2 == NULL) && ...) S1
|
- BUG_ON(x@p2 == NULL);
)
// </smpl>

Signed-off-by: Julia Lawall <julia@diku.dk>

---
 drivers/net/au1000_eth.c            |    1 -
 1 files changed, 0 insertions(+), 1 deletions(-)

diff --git a/drivers/net/au1000_eth.c b/drivers/net/au1000_eth.c
index ecc2573..9c875bb 100644
--- a/drivers/net/au1000_eth.c
+++ b/drivers/net/au1000_eth.c
@@ -353,7 +353,6 @@ static int mii_probe (struct net_device *dev)
 	}
 
 	/* now we are supposed to have a proper phydev, to attach to... */
-	BUG_ON(!phydev);
 	BUG_ON(phydev->attached_dev);
 
 	phydev = phy_connect(dev, phydev->dev.bus_id, &au1000_adjust_link, 0,
