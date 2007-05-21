From: Auke Kok <auke-jan.h.kok@intel.com>
Subject: [PATCH] e1000: Don't enable polling in open() (was: e1000: assertion
	hit in e1000_clean(), kernel 2.6.21.1)
Date: Mon, 21 May 2007 08:32:41 -0700
Message-ID: <20070521153240.5535.31658.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jesse.brandeburg@intel.com,
	auke-jan.h.kok@intel.com
To: herbert@gondor.apana.org.au, cebbert@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:5472 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752449AbXEUPco (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 21 May 2007 11:32:44 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Herbert Xy wrote:
"netif_poll_enable can only be called if you've previously called
netif_poll_disable.  Otherwise a poll might already be in action
and you may get a crash like this."

Removing the call to netif_poll_enable in e1000_open should fix this issue,
the only other call to netif_poll_enable is in e1000_up() which is only
reached after a device reset or resume.

Signed-off-by: Auke Kok <auke-jan.h.kok@intel.com>
Cc: Herbert Xu <herbert@gondor.apana.org.au>
---

 drivers/net/e1000/e1000_main.c |    4 ----
 1 files changed, 0 insertions(+), 4 deletions(-)

diff --git a/drivers/net/e1000/e1000_main.c b/drivers/net/e1000/e1000_main.c
index 49be393..cbc7feb 100644
--- a/drivers/net/e1000/e1000_main.c
+++ b/drivers/net/e1000/e1000_main.c
@@ -1431,10 +1431,6 @@ e1000_open(struct net_device *netdev)
 	/* From here on the code is the same as e1000_up() */
 	clear_bit(__E1000_DOWN, &adapter->flags);
 
-#ifdef CONFIG_E1000_NAPI
-	netif_poll_enable(netdev);
-#endif
-
 	e1000_irq_enable(adapter);
 
 	/* fire a link status change interrupt to start the watchdog */
