From: Christophe Leroy <christophe.leroy@c-s.fr>
Subject: [PATCH] net: fs_enet: mask interrupts for TX partial frames.
Date: Tue, 11 Aug 2015 12:11:03 +0200 (CEST)
Message-ID: <20150811101103.045721A2414@localhost.localdomain>
Cc: linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org,
	netdev@vger.kernel.org
To: Pantelis Antoniou <pantelis.antoniou@gmail.com>,
	Vitaly Bordug <vbordug@ru.mvista.com>, davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

We are not interested in interrupts for partially transmitted frames.
Unlike SCC and FCC, the FEC doesn't handle the I bit in buffer
descriptors, instead it defines two interrupt bits, TXB and TXF.

We have to mask TXB in order to only get interrupts once the
frame is fully transmitted.

Signed-off-by: Christophe Leroy <christophe.leroy@c-s.fr>
---
 drivers/net/ethernet/freescale/fs_enet/mac-fec.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/freescale/fs_enet/mac-fec.c b/drivers/net/ethernet/freescale/fs_enet/mac-fec.c
index b34214e..016743e 100644
--- a/drivers/net/ethernet/freescale/fs_enet/mac-fec.c
+++ b/drivers/net/ethernet/freescale/fs_enet/mac-fec.c
@@ -110,7 +110,7 @@ static int do_pd_setup(struct fs_enet_private *fep)
 }
 
 #define FEC_NAPI_RX_EVENT_MSK	(FEC_ENET_RXF | FEC_ENET_RXB)
-#define FEC_NAPI_TX_EVENT_MSK	(FEC_ENET_TXF | FEC_ENET_TXB)
+#define FEC_NAPI_TX_EVENT_MSK	(FEC_ENET_TXF)
 #define FEC_RX_EVENT		(FEC_ENET_RXF)
 #define FEC_TX_EVENT		(FEC_ENET_TXF)
 #define FEC_ERR_EVENT_MSK	(FEC_ENET_HBERR | FEC_ENET_BABR | \
-- 
2.1.0
