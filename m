From: Julia Lawall <julia@diku.dk>
Subject: [PATCH 5/9] drivers/net/wireless: correct error-handling code
Date: Tue, 28 Jul 2009 17:54:24 +0200 (CEST)
Message-ID: <Pine.LNX.4.64.0907281753540.28189@ask.diku.dk>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
To: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	kernel-janitors@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mgw1.diku.dk ([130.225.96.91]:55156 "EHLO mgw1.diku.dk"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754547AbZG1Py1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 28 Jul 2009 11:54:27 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Julia Lawall <julia@diku.dk>

iwm_wdev_alloc returns an ERR_PTR value in an error case instead of NULL.

A simplified version of the semantic match that finds this problem is as
follows: (http://coccinelle.lip6.fr/)

// <smpl>
@match exists@
expression x, E;
statement S1, S2;
@@

x = iwm_wdev_alloc(...)
... when != x = E
(
*  if (x == NULL || ...) S1 else S2
|
*  if (x == NULL && ...) S1 else S2
)
// </smpl>

Signed-off-by: Julia Lawall <julia@diku.dk>

---
 drivers/net/wireless/iwmc3200wifi/netdev.c     |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/wireless/iwmc3200wifi/netdev.c b/drivers/net/wireless/iwmc3200wifi/netdev.c
index bb71f8a..e1c6693 100644
--- a/drivers/net/wireless/iwmc3200wifi/netdev.c
+++ b/drivers/net/wireless/iwmc3200wifi/netdev.c
@@ -99,7 +99,7 @@ void *iwm_if_alloc(int sizeof_bus, struct device *dev,
 	int ret = 0;
 
 	wdev = iwm_wdev_alloc(sizeof_bus, dev);
-	if (!wdev) {
+	if (IS_ERR(wdev)) {
 		dev_err(dev, "no memory for wireless device instance\n");
 		return ERR_PTR(-ENOMEM);
 	}
