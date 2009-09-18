From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-2.6 PATCH 1/3] ixgbe: fix sfp_timer clean up in ixgbe_down
Date: Fri, 18 Sep 2009 12:45:43 -0700
Message-ID: <20090918194533.28898.49436.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	Shannon Nelson <shannon.nelson@intel.com>,
	Don Skidmore <donald.c.skidmore@intel.com>,
	Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta01.westchester.pa.mail.comcast.net ([76.96.62.16]:59837
	"EHLO QMTA01.westchester.pa.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751769AbZIRTqB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Sep 2009 15:46:01 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Don Skidmore <donald.c.skidmore@intel.com>

We weren't stoping the sfp_timer after the device was brought down.
This patch properly cleans up.

Signed-off-by: Shannon Nelson <shannon.nelson@intel.com>
Signed-off-by: Don Skidmore <donald.c.skidmore@intel.com>
Acked-by: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/ixgbe/ixgbe_main.c |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/drivers/net/ixgbe/ixgbe_main.c b/drivers/net/ixgbe/ixgbe_main.c
index 59ad959..056434c 100644
--- a/drivers/net/ixgbe/ixgbe_main.c
+++ b/drivers/net/ixgbe/ixgbe_main.c
@@ -2926,6 +2926,8 @@ void ixgbe_down(struct ixgbe_adapter *adapter)
 
 	ixgbe_napi_disable_all(adapter);
 
+	clear_bit(__IXGBE_SFP_MODULE_NOT_FOUND, &adapter->state);
+	del_timer_sync(&adapter->sfp_timer);
 	del_timer_sync(&adapter->watchdog_timer);
 	cancel_work_sync(&adapter->watchdog_task);
 

