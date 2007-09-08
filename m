From: ebiederm@xmission.com (Eric W. Biederman)
Subject: [PATCH 05/16] net: Add a network namespace tag to struct net_device
Date: Sat, 08 Sep 2007 15:18:12 -0600
Message-ID: <m1642kx3e3.fsf_-_@ebiederm.dsl.xmission.com>
References: <m1r6l8x3vq.fsf@ebiederm.dsl.xmission.com>
	<m1myvwx3sf.fsf@ebiederm.dsl.xmission.com>
	<m1ir6kx3mn.fsf_-_@ebiederm.dsl.xmission.com>
	<m1ejh8x3ih.fsf_-_@ebiederm.dsl.xmission.com>
	<m1abrwx3g0.fsf_-_@ebiederm.dsl.xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: <netdev@vger.kernel.org>,
	Linux Containers <containers@lists.osdl.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ebiederm.dsl.xmission.com ([166.70.28.69]:46392 "EHLO
	ebiederm.dsl.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752731AbXIHVSh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 8 Sep 2007 17:18:37 -0400
In-Reply-To: <m1abrwx3g0.fsf_-_@ebiederm.dsl.xmission.com> (Eric
	W. Biederman's message of "Sat, 08 Sep 2007 15:17:03 -0600")
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


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
index 9b26594..8eeced0 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -41,6 +41,7 @@
 #include <linux/dmaengine.h>
 #include <linux/workqueue.h>
 
+struct net;
 struct vlan_group;
 struct ethtool_ops;
 struct netpoll_info;
@@ -649,6 +650,9 @@ struct net_device
 	void                    (*poll_controller)(struct net_device *dev);
 #endif
 
+	/* Network namespace this network device is inside */
+	struct net		*nd_net;
+
 	/* bridge stuff */
 	struct net_bridge_port	*br_port;
 	/* macvlan */
-- 
1.5.3.rc6.17.g1911

