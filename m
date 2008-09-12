From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [NET-NEXT PATCH 1/3] vlan: vlan device not reading gso max size of
	parent.
Date: Thu, 11 Sep 2008 20:07:47 -0700
Message-ID: <20080912030733.6982.49986.stgit@jtkirshe-mobile.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: jeff@garzik.org, netdev@vger.kernel.org, akpm@linux-foundation.org,
	Alexander Duyck <alexander.h.duyck@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from wf-out-1314.google.com ([209.85.200.170]:17517 "EHLO
	wf-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751521AbYILDHu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Sep 2008 23:07:50 -0400
Received: by wf-out-1314.google.com with SMTP id 27so624675wfd.4
        for <netdev@vger.kernel.org>; Thu, 11 Sep 2008 20:07:49 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@intel.com>

The vlan devices are not reading the gso max size of the parent device.  As
a result devices that do not support 64K max gso size are currently
failing.

This issue is seen on 2.6.26 kernels as well and the same patch should be
able to be applied without any issues.

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 net/8021q/vlan.c     |    1 +
 net/8021q/vlan_dev.c |    1 +
 2 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/net/8021q/vlan.c b/net/8021q/vlan.c
index b661f47..f0e335a 100644
--- a/net/8021q/vlan.c
+++ b/net/8021q/vlan.c
@@ -394,6 +394,7 @@ static void vlan_transfer_features(struct net_device *dev,
 
 	vlandev->features &= ~dev->vlan_features;
 	vlandev->features |= dev->features & dev->vlan_features;
+	vlandev->gso_max_size = dev->gso_max_size;
 
 	if (old_features != vlandev->features)
 		netdev_features_change(vlandev);
diff --git a/net/8021q/vlan_dev.c b/net/8021q/vlan_dev.c
index 4bf014e..97688cd 100644
--- a/net/8021q/vlan_dev.c
+++ b/net/8021q/vlan_dev.c
@@ -607,6 +607,7 @@ static int vlan_dev_init(struct net_device *dev)
 		      (1<<__LINK_STATE_PRESENT);
 
 	dev->features |= real_dev->features & real_dev->vlan_features;
+	dev->gso_max_size = real_dev->gso_max_size;
 
 	/* ipv6 shared card related stuff */
 	dev->dev_id = real_dev->dev_id;

