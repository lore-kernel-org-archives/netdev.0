From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next PATCH 1/8] net: Add ndo_fcoe_enable/ndo_fcoe_disable to
	net_device_ops
Date: Mon, 31 Aug 2009 15:31:36 -0700
Message-ID: <20090831223110.30995.61162.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	Yi Zou <yi.zou@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta03.emeryville.ca.mail.comcast.net ([76.96.30.32]:47501 "EHLO
	QMTA03.emeryville.ca.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751093AbZHaWbv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 31 Aug 2009 18:31:51 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Yi Zou <yi.zou@intel.com>

Add ndo_fcoe_enable/_disable to net_device_ops so the corresponding
HW can initialize itself for FCoE traffic or clean up after FCoE traffic is
done. This is expected to be called by the kernel FCoE stack upon receiving
a request for creating an FCoE instance on the corresponding netdev interface.
When implemented by the actual HW, the HW driver check the op code to perform
corresponding initialization or clean up for FCoE. The initialization normally
includes allocating extra queues for FCoE, setting corresponding HW registers
for FCoE, indicating FCoE offload features via netdev, etc. The clean-up would
include releasing the resources allocated for FCoE.

Signed-off-by: Yi Zou <yi.zou@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 include/linux/netdevice.h |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 60d3aac..e05c41e 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -623,6 +623,8 @@ struct net_device_ops {
 	void                    (*ndo_poll_controller)(struct net_device *dev);
 #endif
 #if defined(CONFIG_FCOE) || defined(CONFIG_FCOE_MODULE)
+	int			(*ndo_fcoe_enable)(struct net_device *dev);
+	int			(*ndo_fcoe_disable)(struct net_device *dev);
 	int			(*ndo_fcoe_ddp_setup)(struct net_device *dev,
 						      u16 xid,
 						      struct scatterlist *sgl,

