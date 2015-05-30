From: Tomas Krcka <tomas.krcka@nkgroup.cz>
Subject: [PATCH v2] can: mcp251x: not correct register address
Date: Sat, 30 May 2015 11:42:57 +0200
Message-ID: <55698621.7070309@nkgroup.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: moorray3@wp.pl, mkl@pengutronix.de, himangi774@gmail.com,
	netdev@vger.kernel.org
To: linux-can@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f181.google.com ([209.85.212.181]:37233 "EHLO
	mail-wi0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752574AbbE3JnA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 30 May 2015 05:43:00 -0400
Received: by wifw1 with SMTP id w1so50351012wif.0
        for <netdev@vger.kernel.org>; Sat, 30 May 2015 02:42:58 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

v2: fix of corrupted patch

This patch corrects addresses of acceptance filters.
These registers are not in use, but values should be correct.
Tested with MCP2515 and am3352 and also checked datasheets for MCP2515
and MCP2510.

Signed-off-by: Tomas Krcka <tomas.krcka@nkgroup.cz> 

---
 drivers/net/can/spi/mcp251x.c |    9 +++++----
 1 files changed, 5 insertions(+), 4 deletions(-)

diff --git a/drivers/net/can/spi/mcp251x.c b/drivers/net/can/spi/mcp251x.c
index bf63fee..c1a95a3 100644
--- a/drivers/net/can/spi/mcp251x.c
+++ b/drivers/net/can/spi/mcp251x.c
@@ -190,10 +190,11 @@
 #define RXBEID0_OFF 4
 #define RXBDLC_OFF  5
 #define RXBDAT_OFF  6
-#define RXFSIDH(n) ((n) * 4)
-#define RXFSIDL(n) ((n) * 4 + 1)
-#define RXFEID8(n) ((n) * 4 + 2)
-#define RXFEID0(n) ((n) * 4 + 3)
+#define RXFSID(n) ((n < 3) ? 0 : 4)
+#define RXFSIDH(n) ((n) * 4 + RXFSID(n))
+#define RXFSIDL(n) ((n) * 4 + 1 + RXFSID(n))
+#define RXFEID8(n) ((n) * 4 + 2 + RXFSID(n))
+#define RXFEID0(n) ((n) * 4 + 3 + RXFSID(n))
 #define RXMSIDH(n) ((n) * 4 + 0x20)
 #define RXMSIDL(n) ((n) * 4 + 0x21)
 #define RXMEID8(n) ((n) * 4 + 0x22)
-- 
1.7.5.4
