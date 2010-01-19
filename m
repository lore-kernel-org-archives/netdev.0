From: Mike Frysinger <vapier@gentoo.org>
Subject: [PATCH 5/6] netdev: bfin_mac: clear RXCKS if hardware generated checksum is not enabled
Date: Tue, 19 Jan 2010 06:08:26 -0500
Message-ID: <1263899307-10627-5-git-send-email-vapier@gentoo.org>
References: <1263899307-10627-1-git-send-email-vapier@gentoo.org>
Cc: uclinux-dist-devel@blackfin.uclinux.org,
	Sonic Zhang <sonic.zhang@analog.com>
To: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.gentoo.org ([140.211.166.183]:59093 "EHLO smtp.gentoo.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755991Ab0ASLIU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 19 Jan 2010 06:08:20 -0500
In-Reply-To: <1263899307-10627-1-git-send-email-vapier@gentoo.org>
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
index 112d13e..af45f65 100644
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
1.6.6

