From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH -next] bridge: fix build for CONFIG_SYSFS disabled
Date: Tue, 18 May 2010 10:28:37 -0700
Message-ID: <20100518102837.2622c3b1@nehalam>
References: <20100517091756.e232bdc2.randy.dunlap@oracle.com>
	<20100517105654.2451e61f@nehalam>
	<4BF18468.5010005@oracle.com>
	<20100517.223237.55871633.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: randy.dunlap@oracle.com, sfr@canb.auug.org.au,
	linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-next-owner@vger.kernel.org>
In-Reply-To: <20100517.223237.55871633.davem@davemloft.net>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


From: Randy Dunlap <randy.dunlap@oracle.com>

Fix build when CONFIG_SYSFS is not enabled:
net/bridge/br_if.c:136: error: 'struct net_bridge_port' has no member named 'sysfs_name'

Note: dev->name == sysfs_name except when change name is in
progress, and we are protected from that by RTNL mutex.

Signed-off-by: Randy Dunlap <randy.dunlap@oracle.com>
Acked-off-by: Stephen Hemminger <shemminger@vyatta.com>


--- a/net/bridge/br_if.c	2010-05-17 10:51:48.638634187 -0700
+++ b/net/bridge/br_if.c	2010-05-18 10:22:28.892111158 -0700
@@ -133,7 +133,7 @@ static void del_nbp(struct net_bridge_po
 	struct net_bridge *br = p->br;
 	struct net_device *dev = p->dev;
 
-	sysfs_remove_link(br->ifobj, p->sysfs_name);
+	sysfs_remove_link(br->ifobj, p->dev->name);
 
 	dev_set_promiscuity(dev, -1);
 
