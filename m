From: David Miller <davem@davemloft.net>
Subject: [PATCH 1/6]: net: Remove bogus reference to BUS_ID_SIZE in sysfs
 code.
Date: Tue, 26 May 2009 21:39:49 -0700 (PDT)
Message-ID: <20090526.213949.187926678.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kay.sievers@vrfy.org, greg@kroah.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:48662
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751891AbZE0Eju (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 May 2009 00:39:50 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


BUS_ID_SIZE is really no more, and device names are dynamically
allocated and thus can be any necessary size.

So remove the BUG check here making sure BUS_ID_SIZE is at least
as large as IFNAMSIZ.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 net/core/net-sysfs.c |    1 -
 1 files changed, 0 insertions(+), 1 deletions(-)

diff --git a/net/core/net-sysfs.c b/net/core/net-sysfs.c
index b9641e8..3994680 100644
--- a/net/core/net-sysfs.c
+++ b/net/core/net-sysfs.c
@@ -499,7 +499,6 @@ int netdev_register_kobject(struct net_device *net)
 	dev->platform_data = net;
 	dev->groups = groups;
 
-	BUILD_BUG_ON(BUS_ID_SIZE < IFNAMSIZ);
 	dev_set_name(dev, "%s", net->name);
 
 #ifdef CONFIG_SYSFS
-- 
1.6.3

