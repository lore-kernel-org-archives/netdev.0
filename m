From: Tomas Krcka <tomas.krcka@nkgroup.cz>
Subject: [PATCH] can: mcp251x: not correct register address
Date: Mon, 25 May 2015 08:57:48 +0200
Message-ID: <CAAJk-V21bpKN8vX86uQLA0Uo-NTjry+CtfE+1wNK9yJmaVSTVw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: andri.yngvason@marel.com, mkl@pengutronix.de, himangi774@gmail.com,
	netdev@vger.kernel.org
To: linux-can@vger.kernel.org
Return-path: <linux-can-owner@vger.kernel.org>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

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
