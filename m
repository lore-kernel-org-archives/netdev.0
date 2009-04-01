From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [PATCH 7/9] ixgbe: Patch to fix driver panic while freeing up tx & rx
	resources
Date: Wed, 01 Apr 2009 00:34:44 -0700
Message-ID: <20090401073444.3749.94296.stgit@lost.foo-projects.org>
References: <20090401073241.3749.36391.stgit@lost.foo-projects.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	Mallikarjuna R Chilakala <mallikarjuna.chilakala@intel.com>,
	Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta02.westchester.pa.mail.comcast.net ([76.96.62.24]:36944
	"EHLO QMTA02.westchester.pa.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1758399AbZDAHfH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Apr 2009 03:35:07 -0400
In-Reply-To: <20090401073241.3749.36391.stgit@lost.foo-projects.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mallikarjuna R Chilakala <mallikarjuna.chilakala@intel.com>

When network interface is made active we were not handling the error
scenarios properly to clean up rx & tx resources which might result in
a driver panic.

Signed-off-by: Mallikarjuna R Chilakala <mallikarjuna.chilakala@intel.com>
Acked-by: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/ixgbe/ixgbe_main.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ixgbe/ixgbe_main.c b/drivers/net/ixgbe/ixgbe_main.c
index f36cff5..ae2af45 100644
--- a/drivers/net/ixgbe/ixgbe_main.c
+++ b/drivers/net/ixgbe/ixgbe_main.c
@@ -3486,10 +3486,10 @@ err_up:
 	ixgbe_release_hw_control(adapter);
 	ixgbe_free_irq(adapter);
 err_req_irq:
-	ixgbe_free_all_rx_resources(adapter);
 err_setup_rx:
-	ixgbe_free_all_tx_resources(adapter);
+	ixgbe_free_all_rx_resources(adapter);
 err_setup_tx:
+	ixgbe_free_all_tx_resources(adapter);
 	ixgbe_reset(adapter);
 
 	return err;

