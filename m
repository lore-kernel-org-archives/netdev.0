From: Julia Lawall <julia@diku.dk>
Subject: [PATCH 7/13] drivers/net/wan: Remove redundant test
Date: Sun, 21 Dec 2008 16:39:15 +0100 (CET)
Message-ID: <Pine.LNX.4.64.0812211638550.9555@pc-004.diku.dk>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
To: khc@pm.waw.pl, jgarzik@pobox.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, kernel-janitors@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mgw2.diku.dk ([130.225.96.92]:58978 "EHLO mgw2.diku.dk"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755054AbYLUPjS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 21 Dec 2008 10:39:18 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Julia Lawall <julia@diku.dk>

arg is checked not to be NULL a few lines before.

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
 drivers/net/wan/pc300_drv.c         |    5 ++---
 1 files changed, 2 insertions(+), 3 deletions(-)

diff --git a/drivers/net/wan/pc300_drv.c b/drivers/net/wan/pc300_drv.c
index d67957a..c23fde0 100644
--- a/drivers/net/wan/pc300_drv.c
+++ b/drivers/net/wan/pc300_drv.c
@@ -2718,9 +2718,8 @@ static int cpc_ioctl(struct net_device *dev, struct ifreq *ifr, int cmd)
 					}
 					pc300patrntst.num_errors =
 						falc_pattern_test_error(card, ch);
-					if (!arg
-					    || copy_to_user(arg, &pc300patrntst,
-							    sizeof (pc300patterntst_t)))
+					if (copy_to_user(arg, &pc300patrntst,
+							 sizeof(pc300patterntst_t)))
 							return -EINVAL;
 				} else {
 					falc_pattern_test(card, ch, pc300patrntst.patrntst_on);
