From: Atsushi Nemoto <anemo@mba.ocn.ne.jp>
Subject: [PATCH] tc35815: Fix build error if NAPI enabled
Date: Wed,  1 Apr 2009 00:05:02 +0900
Message-ID: <1238511902-6853-1-git-send-email-anemo@mba.ocn.ne.jp>
Cc: Stephen Hemminger <shemminger@linux-foundation.org>,
	netdev@vger.kernel.org
To: Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mba.ocn.ne.jp ([122.1.235.107]:53636 "EHLO smtp.mba.ocn.ne.jp"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759048AbZCaPFG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 31 Mar 2009 11:05:06 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This driver contains experimental NAPI code disabled by default.
The commit bea3348ee ("[NET]: Make NAPI polling independent of struct
net_device objects.") converted the NAPI path of this driver but that
conversion was not complete.  This patch fixes a build error
introduced by the commit.

Signed-off-by: Atsushi Nemoto <anemo@mba.ocn.ne.jp>
---
 drivers/net/tc35815.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/tc35815.c b/drivers/net/tc35815.c
index bcd0e60..ad9848e 100644
--- a/drivers/net/tc35815.c
+++ b/drivers/net/tc35815.c
@@ -1908,7 +1908,7 @@ static int tc35815_poll(struct napi_struct *napi, int budget)
 	do {
 		tc_writel(status, &tr->Int_Src);	/* write to clear */
 
-		handled = tc35815_do_interrupt(dev, status, limit);
+		handled = tc35815_do_interrupt(dev, status, budget - received);
 		if (handled >= 0) {
 			received += handled;
 			if (received >= budget)
-- 
1.5.6.3

