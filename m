From: Davide Ciminaghi <ciminaghi@gnudd.com>
Subject: [PATCH] net/ethernet: ks8851_mll fix rx frame buffer overflow
Date: Tue, 27 Mar 2012 15:01:44 +0200
Message-ID: <20120327130144.GA555@recalcati>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: raffaele.recalcati@bticino.it
To: "David S. Miller" <davem@davemloft.net>,
	Alexey Dobriyan <adobriyan@gmail.com>,
	Thomas Meyer <thomas@m3y3r.de>,
	Wan ZongShun <mcuos.com@gmail.com>,
	Lucas De Marchi <lucas.demarchi@profusion.mobi>,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.bticino.it ([91.208.195.91]:59474 "EHLO bticino.it"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751524Ab2C0NUz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 27 Mar 2012 09:20:55 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If interrupts are disabled long enough to allow for more than
32 frames to accumulate in the MAC's internal buffers, a buffer
overflow occurs. This patch fixes the problem by making the
driver's frame_head_info buffer bigger enough.

Signed-off-by: Davide Ciminaghi <ciminaghi@gnudd.com>
Signed-off-by: Raffaele Recalcati <raffaele.recalcati@bticino.it>
---
 drivers/net/ethernet/micrel/ks8851_mll.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ethernet/micrel/ks8851_mll.c b/drivers/net/ethernet/micrel/ks8851_mll.c
index 2784bc7..a158e89 100644
--- a/drivers/net/ethernet/micrel/ks8851_mll.c
+++ b/drivers/net/ethernet/micrel/ks8851_mll.c
@@ -40,7 +40,7 @@
 #define	DRV_NAME	"ks8851_mll"
 
 static u8 KS_DEFAULT_MAC_ADDRESS[] = { 0x00, 0x10, 0xA1, 0x86, 0x95, 0x11 };
-#define MAX_RECV_FRAMES			32
+#define MAX_RECV_FRAMES			256
 #define MAX_BUF_SIZE			2048
 #define TX_BUF_SIZE			2000
 #define RX_BUF_SIZE			2000
-- 
1.7.0.4
