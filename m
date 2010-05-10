From: Mike Frysinger <vapier@gentoo.org>
Subject: [PATCH 7/9] netdev: bfin_mac: use promiscuous flag for promiscuous mode
Date: Mon, 10 May 2010 11:39:12 -0400
Message-ID: <1273505954-32588-7-git-send-email-vapier@gentoo.org>
References: <1273505954-32588-1-git-send-email-vapier@gentoo.org>
Cc: uclinux-dist-devel@blackfin.uclinux.org,
	Sonic Zhang <sonic.zhang@analog.com>
To: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.gentoo.org ([140.211.166.183]:43500 "EHLO smtp.gentoo.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753382Ab0EJPg0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 10 May 2010 11:36:26 -0400
In-Reply-To: <1273505954-32588-1-git-send-email-vapier@gentoo.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sonic Zhang <sonic.zhang@analog.com>

Rather than using the Receive All Frames (RAF) bit to enable promiscuous
mode, use the Promiscuous (PR) bit.  This lowers overhead at runtime as
we let the hardware process the packets that should actually be checked.

Signed-off-by: Sonic Zhang <sonic.zhang@analog.com>
Signed-off-by: Mike Frysinger <vapier@gentoo.org>
---
 drivers/net/bfin_mac.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/bfin_mac.c b/drivers/net/bfin_mac.c
index 967d018..6f5ee1a 100644
--- a/drivers/net/bfin_mac.c
+++ b/drivers/net/bfin_mac.c
@@ -1279,7 +1279,7 @@ static void bfin_mac_set_multicast_list(struct net_device *dev)
 	if (dev->flags & IFF_PROMISC) {
 		printk(KERN_INFO "%s: set to promisc mode\n", dev->name);
 		sysctl = bfin_read_EMAC_OPMODE();
-		sysctl |= RAF;
+		sysctl |= PR;
 		bfin_write_EMAC_OPMODE(sysctl);
 	} else if (dev->flags & IFF_ALLMULTI) {
 		/* accept all multicast */
-- 
1.7.1

