From: <Narendra_K@Dell.com>
Subject: [RFC PATCH] Initialize dev_id sysfs attribute to -1 by default
Date: Thu, 30 May 2013 18:55:47 +0530
Message-ID: <20130530132419.GA1368@fedora-17-guest.blr.amer.dell.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: <bhutchings@solarflare.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ausxippc101.us.dell.com ([143.166.85.207]:15192 "EHLO
	ausxippc101.us.dell.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751765Ab3E3N0o convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 May 2013 09:26:44 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Narendra K <narendra_k@dell.com>

'dev_id' sysfs attribute is initialized to zero by default.
It is also zero based. This creates ambiguity in differentiating
whether the driver set it to zero or it is the default value.
Initialize 'dev_id' to -1 to make the scenario unambiguous.

Signed-off-by: Narendra K <narendra_k@dell.com>
---
The patch applies to net-next tree.

 include/linux/netdevice.h | 2 +-
 net/core/dev.c            | 1 +
 2 files changed, 2 insertions(+), 1 deletion(-)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 8f967e3..986867e 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -1142,7 +1142,7 @@ struct net_device {
 	unsigned char		addr_assign_type; /* hw address assignment type */
 	unsigned char		addr_len;	/* hardware address length	*/
 	unsigned char		neigh_priv_len;
-	unsigned short          dev_id;		/* for shared network cards */
+	short 			dev_id;		/* physical port number */
 
 	spinlock_t		addr_list_lock;
 	struct netdev_hw_addr_list	uc;	/* Unicast mac addresses */
diff --git a/net/core/dev.c b/net/core/dev.c
index d4d874a..aca6002 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -5727,6 +5727,7 @@ struct net_device *alloc_netdev_mqs(int sizeof_priv, const char *name,
 	INIT_LIST_HEAD(&dev->upper_dev_list);
 	dev->priv_flags = IFF_XMIT_DST_RELEASE;
 	setup(dev);
+	dev->dev_id = -1;
 
 	dev->num_tx_queues = txqs;
 	dev->real_num_tx_queues = txqs;
-- 
1.8.0.1

-- 
With regards,
Narendra K
Linux Engineering
Dell Inc.
