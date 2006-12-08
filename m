From: "Kok, Auke" <auke-jan.h.kok@intel.com>
Subject: [PATCH 11/22] e1000: Fire a link even interrupt instead of a watchdog at init.
Date: Fri, 08 Dec 2006 15:03:09 -0800
Message-ID: <20061208230309.30109.51216.stgit@gitlost.site>
References: <20061208230209.30109.49157.stgit@gitlost.site>
Cc: netdev@vger.kernel.org,
	"Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	"Kok, Auke" <auke-jan.h.kok@intel.com>,
	"Kok, Auke" <auke@foo-projects.org>,
	"Ronciak, John" <john.ronciak@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [63.64.152.142] ([63.64.152.142]:4387 "EHLO gitlost.site"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1761263AbWLHWxF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 8 Dec 2006 17:53:05 -0500
To: "Garzik, Jeff" <jgarzik@pobox.com>
In-Reply-To: <20061208230209.30109.49157.stgit@gitlost.site>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Instead of calling a watchdog event we let our interrupt handler
cascade a link event. This allows us to spot link up immediately
after _up() without racing against a new watchdog.

Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
Signed-off-by: Auke Kok <auke-jan.h.kok@intel.com>
---

 drivers/net/e1000/e1000_main.c |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/drivers/net/e1000/e1000_main.c b/drivers/net/e1000/e1000_main.c
index 0ebd8e2..c5c764f 100644
--- a/drivers/net/e1000/e1000_main.c
+++ b/drivers/net/e1000/e1000_main.c
@@ -558,7 +558,8 @@ e1000_up(struct e1000_adapter *adapter)
 
 	clear_bit(__E1000_DOWN, &adapter->flags);
 
-	mod_timer(&adapter->watchdog_timer, jiffies + 2 * HZ);
+	/* fire a link change interrupt to start the watchdog */
+	E1000_WRITE_REG(&adapter->hw, ICS, E1000_ICS_LSC);
 	return 0;
 }
 



---
Auke Kok <auke-jan.h.kok@intel.com>
