From: Rickard Strandqvist <rickard_strandqvist@spectrumdigital.se>
Subject: [PATCH] net: wan: wanxl.c:  Cleaning up declaration of a while loop
Date: Sat,  7 Jun 2014 13:03:38 +0200
Message-ID: <1402139018-17208-1-git-send-email-rickard_strandqvist@spectrumdigital.se>
Cc: Rickard Strandqvist <rickard_strandqvist@spectrumdigital.se>,
	linux-kernel@vger.kernel.org
To: Krzysztof Halasa <khc@pm.waw.pl>, netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Unusual declaration of a while loop.
However, believe you also want to make sure that the pointer is not NULL

This was partly found using a static code analysis program called cppcheck.

Signed-off-by: Rickard Strandqvist <rickard_strandqvist@spectrumdigital.se>
---
 drivers/net/wan/wanxl.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/wan/wanxl.c b/drivers/net/wan/wanxl.c
index f76aa90..bde0943 100644
--- a/drivers/net/wan/wanxl.c
+++ b/drivers/net/wan/wanxl.c
@@ -196,7 +196,7 @@ static inline void wanxl_tx_intr(port_t *port)
 static inline void wanxl_rx_intr(card_t *card)
 {
 	desc_t *desc;
-	while (desc = &card->status->rx_descs[card->rx_in],
+	while (desc = &card->status->rx_descs[card->rx_in] &&
 	       desc->stat != PACKET_EMPTY) {
 		if ((desc->stat & PACKET_PORT_MASK) > card->n_ports)
 			pr_crit("%s: received packet for nonexistent port\n",
-- 
1.7.10.4
