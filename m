From: Divy Le Ray <divy@chelsio.com>
Subject: [PATCH 2/2 2.6.28] cxgb3 - Limit multiqueue setting to msi-x
Date: Sun, 09 Nov 2008 00:55:33 -0800
Message-ID: <20081109085533.3558.97321.stgit@speedy5>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	swise@opengridcomputing.com
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([12.22.49.110]:8402 "EHLO
	stargate.chelsio.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754188AbYKIIzi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 9 Nov 2008 03:55:38 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Divy Le Ray <divy@chelsio.com>

Allow multiqueue setting in MSI-X mode only

Signed-off-by: Divy Le Ray <divy@chelsio.com>
---

 drivers/net/cxgb3/cxgb3_main.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/cxgb3/cxgb3_main.c b/drivers/net/cxgb3/cxgb3_main.c
index 1ace41a..f66367e 100644
--- a/drivers/net/cxgb3/cxgb3_main.c
+++ b/drivers/net/cxgb3/cxgb3_main.c
@@ -2699,7 +2699,7 @@ static void set_nqsets(struct adapter *adap)
 	int hwports = adap->params.nports;
 	int nqsets = SGE_QSETS;
 
-	if (adap->params.rev > 0) {
+	if (adap->params.rev > 0 && adap->flags & USING_MSIX) {
 		if (hwports == 2 &&
 		    (hwports * nqsets > SGE_QSETS ||
 		     num_cpus >= nqsets / hwports))

