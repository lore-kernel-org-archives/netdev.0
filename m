From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 08/14] ixgbevf: Add lock around ixgbevf_reinit_locked call
Date: Fri, 22 Jul 2016 23:49:45 -0700
Message-ID: <1469256591-109822-9-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1469256591-109822-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Don Skidmore <donald.c.skidmore@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	guru.anbalagane@oracle.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:62671 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751123AbcGWGuL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 23 Jul 2016 02:50:11 -0400
In-Reply-To: <1469256591-109822-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Don Skidmore <donald.c.skidmore@intel.com>

The function ixgbevf_reinit_locked() assumes you have the rtnl lock
however we didn't when calling from the service task.  This patch
corrects that.

Signed-off-by: Don Skidmore <donald.c.skidmore@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c b/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
index 1bffac3..7dc4245 100644
--- a/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
+++ b/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
@@ -2779,7 +2779,9 @@ static void ixgbevf_reset_subtask(struct ixgbevf_adapter *adapter)
 
 	adapter->tx_timeout_count++;
 
+	rtnl_lock();
 	ixgbevf_reinit_locked(adapter);
+	rtnl_unlock();
 }
 
 /**
-- 
2.5.5
