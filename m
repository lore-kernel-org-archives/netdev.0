From: Mike Frysinger <vapier@gentoo.org>
Subject: [PATCH 05/11] netdev: bfin_mac: clear RXCKS if hardware generated checksum is not enabled
Date: Sun,  9 May 2010 06:18:51 -0400
Message-ID: <1273400337-26501-5-git-send-email-vapier@gentoo.org>
References: <1273400337-26501-1-git-send-email-vapier@gentoo.org>
Cc: uclinux-dist-devel@blackfin.uclinux.org,
	Sonic Zhang <sonic.zhang@analog.com>
To: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.gentoo.org ([140.211.166.183]:53246 "EHLO smtp.gentoo.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752687Ab0EIKQK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 9 May 2010 06:16:10 -0400
In-Reply-To: <1273400337-26501-1-git-send-email-vapier@gentoo.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sonic Zhang <sonic.zhang@analog.com>

Otherwise we might be get a setting mismatch from a previous module or
bootloader and what the driver currently expects.

Signed-off-by: Sonic Zhang <sonic.zhang@analog.com>
Signed-off-by: Mike Frysinger <vapier@gentoo.org>
---
 drivers/net/bfin_mac.c |    5 +++--
 1 files changed, 3 insertions(+), 2 deletions(-)

diff --git a/drivers/net/bfin_mac.c b/drivers/net/bfin_mac.c
index 5b00fc8..6d69bbb 100644
--- a/drivers/net/bfin_mac.c
+++ b/drivers/net/bfin_mac.c
@@ -515,10 +515,11 @@ void setup_system_regs(struct net_device *dev)
 	 * Configure checksum support and rcve frame word alignment
 	 */
 	sysctl = bfin_read_EMAC_SYSCTL();
+	sysctl |= RXDWA;
 #if defined(BFIN_MAC_CSUM_OFFLOAD)
-	sysctl |= RXDWA | RXCKS;
+	sysctl |= RXCKS;
 #else
-	sysctl |= RXDWA;
+	sysctl &= ~RXCKS;
 #endif
 	bfin_write_EMAC_SYSCTL(sysctl);
 
-- 
1.7.1

