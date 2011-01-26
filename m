From: Kiran Patil <kiran.patil@intel.com>
Subject: [RFC PATCH 1/2] net: add ndo_fcoe_ddp_target() to support FCoE DDP in
	target mode
Date: Wed, 26 Jan 2011 10:09:01 -0800
Message-ID: <20110126180901.25039.18150.stgit@localhost.localdomain>
References: <20110126180855.25039.82793.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org, jeffrey.t.kirsher@intel.com,
	yi.zou@intel.com, robert.w.love@intel.com, kiran.patil@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([143.182.124.37]:33899 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751736Ab1AZSHL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 26 Jan 2011 13:07:11 -0500
In-Reply-To: <20110126180855.25039.82793.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Yi Zou <yi.zou@intel.com>

The Fiber Channel over Ethernet (FCoE) Direct Data Placement (DDP) can also be
used for FCoE target, where the DDP used for read I/O on an initiator can be
used on an FCoE target to speed up the write I/O to the target from the initiator.
The added ndo_fcoe_ddp_target() works in the similar way as the existing
ndo_fcoe_ddp_setup() to allow the underlying hardware set up the DDP context
accordingly when it gets called from the FCoE target implementation on top
the existing Open-FCoE fcoe/libfc protocol stack so without losing the ability
to provide DDP for read I/O as an initiator, it can also provide DDP offload
to the write I/O coming from the initiator as a target.

Signed-off-by: Yi Zou <yi.zou@intel.com>
Signed-off-by: Kiran Patil <kiran.patil@intel.com>
---

 include/linux/netdevice.h |    4 ++++
 1 files changed, 4 insertions(+), 0 deletions(-)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index d8fd2c2..d96a198 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -774,6 +774,10 @@ struct net_device_ops {
 						      unsigned int sgc);
 	int			(*ndo_fcoe_ddp_done)(struct net_device *dev,
 						     u16 xid);
+	int			(*ndo_fcoe_ddp_target)(struct net_device *dev,
+						       u16 xid,
+						       struct scatterlist *sgl,
+						       unsigned int sgc);
 #define NETDEV_FCOE_WWNN 0
 #define NETDEV_FCOE_WWPN 1
 	int			(*ndo_fcoe_get_wwn)(struct net_device *dev,

