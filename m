From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next-2.6] net: propagate NETIF_F_HIGHDMA to vlans
Date: Thu, 23 Sep 2010 12:46:11 +0200
Message-ID: <1285238771.2864.38.camel@edumazet-laptop>
References: <20100923035755.11561.14170.stgit@localhost.localdomain>
	 <20100922.212023.91330415.davem@davemloft.net>
	 <1285219690.2380.70.camel@edumazet-laptop>
	 <AANLkTikDdxFho2ioBHMbze685+garDWF9kF3qFXZA9Hr@mail.gmail.com>
	 <1285222405.2380.80.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com, bphilips@novell.com,
	yi.zou@intel.com
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:38241 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752489Ab0IWKqP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Sep 2010 06:46:15 -0400
Received: by fxm12 with SMTP id 12so630673fxm.19
        for <netdev@vger.kernel.org>; Thu, 23 Sep 2010 03:46:14 -0700 (PDT)
In-Reply-To: <1285222405.2380.80.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Automatically allows vlans to get NETIF_F_HIGHDMA if underlying device
supports it.

On 32bit arches (and more precisely if CONFIG_HIGHMEM is enabled), it
can help to reduce cost of illegal_highdma() and __skb_linearize()
calls.

Tested on tg3 , bnx2, bonding, this worked very well.

This is a generalization of a patch provided by Yi Zou & Jeff Kirsher.

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 net/core/dev.c |    7 ++++---
 1 file changed, 4 insertions(+), 3 deletions(-)

diff --git a/net/core/dev.c b/net/core/dev.c
index 2c7934f..e0c0b86 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -5058,10 +5058,11 @@ int register_netdevice(struct net_device *dev)
 	if (dev->features & NETIF_F_SG)
 		dev->features |= NETIF_F_GSO;
 
-	/* Enable GRO for vlans by default if dev->features has GRO also.
-	 * vlan_dev_init() will do the dev->features check.
+	/* Enable GRO and NETIF_F_HIGHDMA for vlans by default,
+	 * vlan_dev_init() will do the dev->features check, so these features
+	 * are enabled only if supported by underlying device.
 	 */
-	dev->vlan_features |= NETIF_F_GRO;
+	dev->vlan_features |= (NETIF_F_GRO | NETIF_F_HIGHDMA);
 
 	ret = call_netdevice_notifiers(NETDEV_POST_INIT, dev);
 	ret = notifier_to_errno(ret);


