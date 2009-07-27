From: Julia Lawall <julia@diku.dk>
Subject: [PATCH 4/12] drivers/net: Correct redundant test
Date: Mon, 27 Jul 2009 18:13:30 +0200 (CEST)
Message-ID: <Pine.LNX.4.64.0907271813120.2682@ask.diku.dk>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
To: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	kernel-janitors@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mgw2.diku.dk ([130.225.96.92]:40830 "EHLO mgw2.diku.dk"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750767AbZG0QQr (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 27 Jul 2009 12:16:47 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Julia Lawall <julia@diku.dk>

res has already been tested.  It seems that this test should be on the
recently returned value mmio.

A simplified version of the semantic match that finds this problem is as
follows: (http://www.emn.fr/x-info/coccinelle/)

// <smpl>
@r exists@
local idexpression x;
expression E;
@@

if (x == NULL || ...) { ... when forall
   return ...; }
... when != \(x=E\|x--\|x++\|--x\|++x\|x-=E\|x+=E\|x|=E\|x&=E\|&x\)
(
*x == NULL
|
*x != NULL
)
// </smpl>

Signed-off-by: Julia Lawall <julia@diku.dk>

---
 drivers/net/ethoc.c                 |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ethoc.c b/drivers/net/ethoc.c
index ceb6a9c..4dbe5f1 100644
--- a/drivers/net/ethoc.c
+++ b/drivers/net/ethoc.c
@@ -894,7 +894,7 @@ static int ethoc_probe(struct platform_device *pdev)
 
 	mmio = devm_request_mem_region(&pdev->dev, res->start,
 			res->end - res->start + 1, res->name);
-	if (!res) {
+	if (!mmio) {
 		dev_err(&pdev->dev, "cannot request I/O memory space\n");
 		ret = -ENXIO;
 		goto free;
