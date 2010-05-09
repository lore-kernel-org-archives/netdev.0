From: Mike Frysinger <vapier@gentoo.org>
Subject: [PATCH 08/11] netdev: bfin_mac: use promiscuous flag for promiscuous mode
Date: Sun,  9 May 2010 06:18:54 -0400
Message-ID: <1273400337-26501-8-git-send-email-vapier@gentoo.org>
References: <1273400337-26501-1-git-send-email-vapier@gentoo.org>
Cc: uclinux-dist-devel@blackfin.uclinux.org,
	Sonic Zhang <sonic.zhang@analog.com>
To: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.gentoo.org ([140.211.166.183]:53266 "EHLO smtp.gentoo.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752541Ab0EIKQO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 9 May 2010 06:16:14 -0400
In-Reply-To: <1273400337-26501-1-git-send-email-vapier@gentoo.org>
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
index e80ccaa..04cda8f 100644
--- a/drivers/net/bfin_mac.c
+++ b/drivers/net/bfin_mac.c
@@ -1274,7 +1274,7 @@ static void bfin_mac_set_multicast_list(struct net_device *dev)
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

