From: Andrew Gallatin <gallatin@myri.com>
Subject: [PATCH net-next 1/1] vlan: restore offload use on vlan transmit
Date: Thu,  6 Dec 2012 15:54:56 -0500
Message-ID: <1354827296-12009-2-git-send-email-gallatin@myri.com>
References: <1354827296-12009-1-git-send-email-gallatin@myri.com>
Cc: netdev@vger.kernel.org, Andrew Gallatin <gallatin@myri.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gh0-f174.google.com ([209.85.160.174]:55684 "EHLO
	mail-gh0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1947192Ab2LFUzH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Dec 2012 15:55:07 -0500
Received: by mail-gh0-f174.google.com with SMTP id g15so1142669ghb.19
        for <netdev@vger.kernel.org>; Thu, 06 Dec 2012 12:55:07 -0800 (PST)
In-Reply-To: <1354827296-12009-1-git-send-email-gallatin@myri.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch copies the vlan device's dev->features to its
dev->vlan_features, which allows packets to arrive at
vlan_dev_hard_start_xmit() with their offloads intact.

When a packet destined for a vlan interface is transmitted, it passes
through dev_hard_start_xmit() (and netif_skb_features()) twice.  First
on its way to vlan_dev_hard_start_xmit(), and then again on its way to
the backing device's xmit handler. If the vlan device does not setup
its dev->vlan_features, then netif_skb_features() will strip the
features on the first trip through it (on the way to
vlan_dev_hard_start_xmit()).

Signed-off-by: Andrew Gallatin <gallatin@myri.com>
---
 net/8021q/vlan_dev.c |    1 +
 1 file changed, 1 insertion(+)

diff --git a/net/8021q/vlan_dev.c b/net/8021q/vlan_dev.c
index 4a6d31a..9d4b3c9 100644
--- a/net/8021q/vlan_dev.c
+++ b/net/8021q/vlan_dev.c
@@ -559,6 +559,7 @@ static int vlan_dev_init(struct net_device *dev)
 
 	dev->features |= real_dev->vlan_features | NETIF_F_LLTX;
 	dev->gso_max_size = real_dev->gso_max_size;
+	dev->vlan_features = dev->features;
 
 	/* ipv6 shared card related stuff */
 	dev->dev_id = real_dev->dev_id;
-- 
1.7.9.5
