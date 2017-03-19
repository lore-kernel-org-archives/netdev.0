From: Gal Pressman <galp@mellanox.com>
Subject: [PATCH ethtool] ethtool: Fix SFF 8079 cable technology bit parsing
Date: Sun, 19 Mar 2017 14:10:41 +0200
Message-ID: <1489925441-20098-1-git-send-email-galp@mellanox.com>
Cc: Gal Pressman <galp@mellanox.com>
To: netdev@vger.kernel.org, "John W. Linville" <linville@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:49139 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1750955AbdCSMLW (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 19 Mar 2017 08:11:22 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

According to the transceiver compliance code definition in the spec, bits
2 & 3 in the 8th byte are indication of active/passive cable, and not
specifically related to FC/copper.

Fixes: 2edf56749abe ("ethtool: Addition of -m option to dump module eeprom")
Signed-off-by: Gal Pressman <galp@mellanox.com>
---
 sfpid.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/sfpid.c b/sfpid.c
index fd6415c..1732e5e 100644
--- a/sfpid.c
+++ b/sfpid.c
@@ -137,9 +137,9 @@ static void sff8079_show_transceiver(const __u8 *id)
 	if (id[8] & (1 << 4))
 		printf("%s FC: Longwave laser (LL)\n", pfx);
 	if (id[8] & (1 << 3))
-		printf("%s FC: Copper Active\n", pfx);
+		printf("%s Active Cable\n", pfx);
 	if (id[8] & (1 << 2))
-		printf("%s FC: Copper Passive\n", pfx);
+		printf("%s Passive Cable\n", pfx);
 	if (id[8] & (1 << 1))
 		printf("%s FC: Copper FC-BaseT\n", pfx);
 	/* Fibre Channel transmission media */
-- 
2.7.4
