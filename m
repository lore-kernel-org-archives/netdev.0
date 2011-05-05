From: Yi Zou <yi.zou@intel.com>
Subject: [PATCH] [RFC] vlan: fix updating wanted_features for vlan device
Date: Wed, 04 May 2011 17:48:42 -0700
Message-ID: <20110505004841.26691.74872.stgit@localhost6.localdomain6>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: mirq-linux@rere.qmqm.pl, jeffrey.t.kirsher@intel.com,
	devel@open-fcoe.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:23741 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752596Ab1EEAd4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 4 May 2011 20:33:56 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

commit 8a0427b "vlan: convert VLAN devices to use ndo_fix_features()" converts the
vlan to support ndo_fix_features. However, the wanted_features is not updated
for the vlan device, causing real_dev->features not be populated to the vlan
device when real_dev->features are changed by the driver through FEAT_CHANGE.
This is breaking FCoE related netdev feature flags on vlan devices. Add updating
wanted_features to vlan_transfer_features() so netdev_get_wanted_features() will
can get the updated wanted feature flags for vlan device properly.

I am sending as RFC in case the usage of wanted_features on vlan device is not
right, since the features chanaged are not directly from user doing ethtool, but
it is from user action of starting to run FCoE on a netdev instance. Anyway, let
let me know if there is a preferred alternative fix.

Signed-off-by: Yi Zou <yi.zou@intel.com>
---

 net/8021q/vlan.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/net/8021q/vlan.c b/net/8021q/vlan.c
index 969e700..f2ee00b 100644
--- a/net/8021q/vlan.c
+++ b/net/8021q/vlan.c
@@ -332,6 +332,7 @@ static void vlan_transfer_features(struct net_device *dev,
 #if defined(CONFIG_FCOE) || defined(CONFIG_FCOE_MODULE)
 	vlandev->fcoe_ddp_xid = dev->fcoe_ddp_xid;
 #endif
+	vlandev->wanted_features |= dev->features & dev->vlan_features;
 
 	netdev_update_features(vlandev);
 }

