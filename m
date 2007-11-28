From: Auke Kok <auke-jan.h.kok@intel.com>
Subject: [PATCH] e1000: Fix NAPI state bug when Rx complete
Date: Tue, 27 Nov 2007 16:26:36 -0800
Message-ID: <20071128002636.26015.28453.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Robert.Olsson@data.slu.se,
	shemminger@linux-foundation.org, davem@davemloft.net
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:28432 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754986AbXK1A2d (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 27 Nov 2007 19:28:33 -0500
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Don't exit polling when we have not yet used our budget, this causes
the NAPI system to end up with a messed up poll list.

Signed-off-by: Auke Kok <auke-jan.h.kok@intel.com>
---

 drivers/net/e1000/e1000_main.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/e1000/e1000_main.c b/drivers/net/e1000/e1000_main.c
index b7c3070..724f067 100644
--- a/drivers/net/e1000/e1000_main.c
+++ b/drivers/net/e1000/e1000_main.c
@@ -3926,7 +3926,7 @@ e1000_clean(struct napi_struct *napi, int budget)
 	                  &work_done, budget);
 
 	/* If no Tx and not enough Rx work done, exit the polling mode */
-	if ((!tx_cleaned && (work_done < budget)) ||
+	if ((!tx_cleaned && (work_done == 0)) ||
 	   !netif_running(poll_dev)) {
 quit_polling:
 		if (likely(adapter->itr_setting & 3))
