From: "Eric W. Biederman" <ebiederm@xmission.com>
Subject: [PATCH RFC 4/31] net: Add a network namespace tag to struct net_device
Date: Thu, 25 Jan 2007 12:00:06 -0700
Message-ID: <11697516343777-git-send-email-ebiederm@xmission.com>
References: <m13b5zym0n.fsf@ebiederm.dsl.xmission.com>
Cc: <containers@lists.osdl.org>, <openib-general@openib.org>,
	"Eric W. Biederman" <ebiederm@xmission.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ebiederm.dsl.xmission.com ([166.70.28.69]:35783 "EHLO
	ebiederm.dsl.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1030244AbXAYTBc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Jan 2007 14:01:32 -0500
In-Reply-To: <m13b5zym0n.fsf@ebiederm.dsl.xmission.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Eric W. Biederman <ebiederm@xmission.com> - unquoted

Please note that network devices do not increase the count
count on the network namespace.  The are inside the network
namespace and so the network namespace tag is in the nature
of a back pointer and so getting and putting the network namespace
is unnecessary.

Signed-off-by: Eric W. Biederman <ebiederm@xmission.com>
---
 include/linux/netdevice.h |    4 ++++
 1 files changed, 4 insertions(+), 0 deletions(-)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 4cb8b39..6a1579d 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -38,6 +38,7 @@
 #include <linux/device.h>
 #include <linux/percpu.h>
 #include <linux/dmaengine.h>
+#include <linux/net_namespace_type.h>
 
 struct vlan_group;
 struct ethtool_ops;
@@ -525,6 +526,9 @@ struct net_device
 	void                    (*poll_controller)(struct net_device *dev);
 #endif
 
+	/* Network namespace this network device is inside */
+	net_t			nd_net;
+
 	/* bridge stuff */
 	struct net_bridge_port	*br_port;
 
-- 
1.4.4.1.g278f

