From: Jesse Gross <jesse@nicira.com>
Subject: [PATCH 1/6] offloading: Accept NETIF_F_HW_CSUM for all protocols.
Date: Sun,  9 Jan 2011 08:23:30 -0800
Message-ID: <1294590215-15541-1-git-send-email-jesse@nicira.com>
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gy0-f174.google.com ([209.85.160.174]:46943 "EHLO
	mail-gy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751800Ab1AIQXm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 9 Jan 2011 11:23:42 -0500
Received: by gyb11 with SMTP id 11so7081593gyb.19
        for <netdev@vger.kernel.org>; Sun, 09 Jan 2011 08:23:41 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We currently only have software fallback for one type of checksum: the
TCP/UDP one's complement.  This means that a protocol that uses hardware
offloading for a different type of checksum (FCoE, SCTP) must directly
check the device's features and do the right thing ahead of time.  By
the time we get to dev_can_checksum(), we're only deciding whether to
apply the one algorithm in software or hardware.  NETIF_F_HW_CSUM has the
same capabilities as the software version, so we should always use it if
present.  The primary advantage of this is multiply tagged vlans can use
hardware checksumming.

Signed-off-by: Jesse Gross <jesse@nicira.com>
---
 net/core/dev.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/core/dev.c b/net/core/dev.c
index a215269..d8befd0 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -1734,7 +1734,7 @@ EXPORT_SYMBOL(netif_device_attach);
 
 static bool can_checksum_protocol(unsigned long features, __be16 protocol)
 {
-	return ((features & NETIF_F_NO_CSUM) ||
+	return ((features & NETIF_F_GEN_CSUM) ||
 		((features & NETIF_F_V4_CSUM) &&
 		 protocol == htons(ETH_P_IP)) ||
 		((features & NETIF_F_V6_CSUM) &&
-- 
1.7.1

