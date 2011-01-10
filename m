From: Vlad Dogaru <ddvlad@rosedu.org>
Subject: [PATCH 2/3] net/dummy: add device group parameter
Date: Mon, 10 Jan 2011 13:38:43 +0200
Message-ID: <1294659524-22509-3-git-send-email-ddvlad@rosedu.org>
References: <1294659524-22509-1-git-send-email-ddvlad@rosedu.org>
Cc: Vlad Dogaru <ddvlad@rosedu.org>, jamal <hadi@cyberus.ca>,
	Octavian Purdila <opurdila@ixiacom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [141.85.37.41] ([141.85.37.41]:33740 "EHLO swarm.cs.pub.ro"
	rhost-flags-FAIL-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1753739Ab1AJLiz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 10 Jan 2011 06:38:55 -0500
To: netdev@vger.kernel.org
In-Reply-To: <1294659524-22509-1-git-send-email-ddvlad@rosedu.org>
To: netdev@vger.kernel.org
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When inserting the dummy module, the user can specify the group of the
dummy devices. This avoids manually moving the newly created pseudo
devices to a different group.

Signed-off-by: Vlad Dogaru <ddvlad@rosedu.org>
---
 drivers/net/dummy.c |    5 +++++
 1 files changed, 5 insertions(+), 0 deletions(-)

diff --git a/drivers/net/dummy.c b/drivers/net/dummy.c
index ff2d29b..a974c05 100644
--- a/drivers/net/dummy.c
+++ b/drivers/net/dummy.c
@@ -39,6 +39,7 @@
 #include <linux/u64_stats_sync.h>
 
 static int numdummies = 1;
+static int ingroup;
 
 static int dummy_set_address(struct net_device *dev, void *p)
 {
@@ -158,6 +159,9 @@ static struct rtnl_link_ops dummy_link_ops __read_mostly = {
 /* Number of dummy devices to be set up by this module. */
 module_param(numdummies, int, 0);
 MODULE_PARM_DESC(numdummies, "Number of dummy pseudo devices");
+/* Group to add the dummy devices to. */
+module_param(ingroup, int, 0);
+MODULE_PARM_DESC(ingroup, "Group the dummy devices belong to");
 
 static int __init dummy_init_one(void)
 {
@@ -167,6 +171,7 @@ static int __init dummy_init_one(void)
 	dev_dummy = alloc_netdev(0, "dummy%d", dummy_setup);
 	if (!dev_dummy)
 		return -ENOMEM;
+	dev_set_group(dev_dummy, ingroup);
 
 	err = dev_alloc_name(dev_dummy, dev_dummy->name);
 	if (err < 0)
-- 
1.7.1

