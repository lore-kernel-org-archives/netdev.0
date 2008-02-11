From: Auke Kok <auke-jan.h.kok@intel.com>
Subject: [PATCH 3/6] e1000e: Fix logic reversal keeping link active
Date: Mon, 11 Feb 2008 09:25:51 -0800
Message-ID: <20080211172551.29090.33075.stgit@localhost.localdomain>
References: <20080211172539.29090.99369.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, e1000-devel@lists.sourceforge.net
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:62829 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755924AbYBKRZ4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 11 Feb 2008 12:25:56 -0500
In-Reply-To: <20080211172539.29090.99369.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

A logic mishap caused the adapter to keep link while we can
disable it due to WoL not being active, and vice versa.

Signed-off-by: Auke Kok <auke-jan.h.kok@intel.com>
---

 drivers/net/e1000e/netdev.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/e1000e/netdev.c b/drivers/net/e1000e/netdev.c
index f58f017..b9b0d32 100644
--- a/drivers/net/e1000e/netdev.c
+++ b/drivers/net/e1000e/netdev.c
@@ -2008,7 +2008,7 @@ static void e1000_power_down_phy(struct e1000_adapter *adapter)
 	u16 mii_reg;
 
 	/* WoL is enabled */
-	if (!adapter->wol)
+	if (adapter->wol)
 		return;
 
 	/* non-copper PHY? */

