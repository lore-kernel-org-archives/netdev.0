From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net 5/6] ixgbe: fix __ixgbe_notify_dca() bail out code
Date: Thu,  4 Aug 2011 05:18:17 -0700
Message-ID: <1312460298-20405-6-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1312460298-20405-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Don Skidmore <donald.c.skidmore@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:1910 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753468Ab1HDMSk (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 4 Aug 2011 08:18:40 -0400
In-Reply-To: <1312460298-20405-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Don Skidmore <donald.c.skidmore@intel.com>

The way __ixgbe_notify_dca() was currently set up it would not be
possible to add a requester. Both cases of the IXGBE_FLAG_DCA_ENABLED
bit being on and off would lead to the function exiting for a
DCA_PROVIDER_ADD.

Signed-off-by: Don Skidmore <donald.c.skidmore@intel.com>
Tested-by: Phil Schmitt <phillip.j.schmitt@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ixgbe/ixgbe_main.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ixgbe/ixgbe_main.c b/drivers/net/ixgbe/ixgbe_main.c
index 26b132b..e86297b 100644
--- a/drivers/net/ixgbe/ixgbe_main.c
+++ b/drivers/net/ixgbe/ixgbe_main.c
@@ -1006,7 +1006,7 @@ static int __ixgbe_notify_dca(struct device *dev, void *data)
 	struct ixgbe_adapter *adapter = dev_get_drvdata(dev);
 	unsigned long event = *(unsigned long *)data;
 
-	if (!(adapter->flags & IXGBE_FLAG_DCA_ENABLED))
+	if (!(adapter->flags & IXGBE_FLAG_DCA_CAPABLE))
 		return 0;
 
 	switch (event) {
-- 
1.7.6

