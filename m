From: Imre Deak <imre.deak@intel.com>
Subject: [PATCH 07/11] net/peak_pcmcia: take msecs_to_jiffies_min into use
Date: Fri, 10 May 2013 15:13:25 +0300
Message-ID: <1368188011-23661-7-git-send-email-imre.deak@intel.com>
References: <1368188011-23661-1-git-send-email-imre.deak@intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>,
	Daniel Vetter <daniel.vetter@ffwll.ch>,
	Wolfgang Grandegger <wg@grandegger.com>,
	Marc Kleine-Budde <mkl@pengutronix.de>,
	Bill Pemberton <wfp5p@virginia.edu>,
	"David S. Miller" <davem@davemloft.net>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	Joe Perches <joe@perches.com>, linux-can@vger.kernel.org,
	netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1368188011-23661-1-git-send-email-imre.deak@intel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Use msecs_to_jiffies_min instead of open-coding the same.

Signed-off-by: Imre Deak <imre.deak@intel.com>
---
 drivers/net/can/sja1000/peak_pcmcia.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/can/sja1000/peak_pcmcia.c b/drivers/net/can/sja1000/peak_pcmcia.c
index 1a7020b..3e45e16 100644
--- a/drivers/net/can/sja1000/peak_pcmcia.c
+++ b/drivers/net/can/sja1000/peak_pcmcia.c
@@ -253,7 +253,7 @@ static inline int pcan_pccard_present(struct pcan_pccard *card)
 static int pcan_wait_spi_busy(struct pcan_pccard *card)
 {
 	unsigned long timeout = jiffies +
-				msecs_to_jiffies(PCC_SPI_MAX_BUSY_WAIT_MS) + 1;
+				msecs_to_jiffies_min(PCC_SPI_MAX_BUSY_WAIT_MS);
 
 	/* be sure to read status at least once after sleeping */
 	while (pcan_read_reg(card, PCC_CSR) & PCC_CSR_SPI_BUSY) {
-- 
1.7.10.4
