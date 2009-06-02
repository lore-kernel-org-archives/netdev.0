From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next PATCH 2/7] e1000e: do not attempt to disable smart
	powerdown if not supported
Date: Tue, 02 Jun 2009 14:28:20 -0700
Message-ID: <20090602212820.24614.4348.stgit@localhost.localdomain>
References: <20090602212800.24614.45798.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	Bruce Allan <bruce.w.allan@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta04.westchester.pa.mail.comcast.net ([76.96.62.40]:56993
	"EHLO QMTA04.westchester.pa.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751611AbZFBV2h (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Jun 2009 17:28:37 -0400
In-Reply-To: <20090602212800.24614.45798.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Bruce Allan <bruce.w.allan@intel.com>

During reset, the driver was attempting to disable the Smart Powerdown
feature even if the part does not support Smart Powerdown.  Check for
support before attempting to disable the feature.

Signed-off-by: Bruce Allan <bruce.w.allan@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/e1000e/netdev.c |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/drivers/net/e1000e/netdev.c b/drivers/net/e1000e/netdev.c
index f012cc6..7e412d1 100644
--- a/drivers/net/e1000e/netdev.c
+++ b/drivers/net/e1000e/netdev.c
@@ -2799,7 +2799,8 @@ void e1000e_reset(struct e1000_adapter *adapter)
 	e1000e_reset_adaptive(hw);
 	e1000_get_phy_info(hw);
 
-	if (!(adapter->flags & FLAG_SMART_POWER_DOWN)) {
+	if ((adapter->flags & FLAG_HAS_SMART_POWER_DOWN) &&
+	    !(adapter->flags & FLAG_SMART_POWER_DOWN)) {
 		u16 phy_data = 0;
 		/*
 		 * speed up time to link by disabling smart power down, ignore

