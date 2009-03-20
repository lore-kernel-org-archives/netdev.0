From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next PATCH 3/5] igb: update driver to use setup_timer function
Date: Fri, 20 Mar 2009 03:17:08 -0700
Message-ID: <20090320101708.17663.50584.stgit@lost.foo-projects.org>
References: <20090320101631.17663.63853.stgit@lost.foo-projects.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	Alexander Duyck <alexander.h.duyck@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta12.emeryville.ca.mail.comcast.net ([76.96.27.227]:55897
	"EHLO QMTA12.emeryville.ca.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757914AbZCTKR0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Mar 2009 06:17:26 -0400
In-Reply-To: <20090320101631.17663.63853.stgit@lost.foo-projects.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@intel.com>

igb was previously setting up all of the timer members itself.  It is
easier to just call setup_timer and reduce the calls to one line.

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/igb/igb_main.c |   11 ++++-------
 1 files changed, 4 insertions(+), 7 deletions(-)

diff --git a/drivers/net/igb/igb_main.c b/drivers/net/igb/igb_main.c
index 05bb7a7..3dd3a5a 100644
--- a/drivers/net/igb/igb_main.c
+++ b/drivers/net/igb/igb_main.c
@@ -1312,13 +1312,10 @@ static int __devinit igb_probe(struct pci_dev *pdev,
 		goto err_eeprom;
 	}
 
-	init_timer(&adapter->watchdog_timer);
-	adapter->watchdog_timer.function = &igb_watchdog;
-	adapter->watchdog_timer.data = (unsigned long) adapter;
-
-	init_timer(&adapter->phy_info_timer);
-	adapter->phy_info_timer.function = &igb_update_phy_info;
-	adapter->phy_info_timer.data = (unsigned long) adapter;
+	setup_timer(&adapter->watchdog_timer, &igb_watchdog,
+	            (unsigned long) adapter);
+	setup_timer(&adapter->phy_info_timer, &igb_update_phy_info,
+	            (unsigned long) adapter);
 
 	INIT_WORK(&adapter->reset_task, igb_reset_task);
 	INIT_WORK(&adapter->watchdog_task, igb_watchdog_task);

