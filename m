From: Christian Riesch <christian.riesch-3mrvs1K0uXizZXS1Dc/lvw@public.gmane.org>
Subject: [PATCH] davinci_cpdma: Fix channel number written to teardown
	registers
Date: Thu, 23 Feb 2012 08:58:00 +0100
Message-ID: <1329983880-23921-1-git-send-email-christian.riesch@omicron.at>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: <davinci-linux-open-source-VycZQUHpC/PFrsHnngEfi1aTQe2KTcn/@public.gmane.org>,
        Ameya Palande
	<ameya.palande-l0cyMroinI0@public.gmane.org>, Ilya Yanok <yanok-qv+LCo8X3VpBDgjK7y7TUQ@public.gmane.org>,
        <linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org>
To: <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Return-path: <davinci-linux-open-source-bounces-VycZQUHpC/PFrsHnngEfi1aTQe2KTcn/@public.gmane.org>
List-Unsubscribe: <http://linux.davincidsp.com/mailman/options/davinci-linux-open-source>,
	<mailto:davinci-linux-open-source-request-VycZQUHpC/PFrsHnngEfi1aTQe2KTcn/@public.gmane.org?subject=unsubscribe>
List-Archive: <http://linux.davincidsp.com/pipermail/davinci-linux-open-source>
List-Post: <mailto:davinci-linux-open-source-VycZQUHpC/PFrsHnngEfi1aTQe2KTcn/@public.gmane.org>
List-Help: <mailto:davinci-linux-open-source-request-VycZQUHpC/PFrsHnngEfi1aTQe2KTcn/@public.gmane.org?subject=help>
List-Subscribe: <http://linux.davincidsp.com/mailman/listinfo/davinci-linux-open-source>,
	<mailto:davinci-linux-open-source-request-VycZQUHpC/PFrsHnngEfi1aTQe2KTcn/@public.gmane.org?subject=subscribe>
Sender: <davinci-linux-open-source-bounces-VycZQUHpC/PFrsHnngEfi1aTQe2KTcn/@public.gmane.org>
Errors-To: davinci-linux-open-source-bounces-VycZQUHpC/PFrsHnngEfi1aTQe2KTcn/@public.gmane.org
List-Id: netdev.vger.kernel.org

chan->chan_num is 0..CPDMA_MAX_CHANNELS-1 for tx channels and
CPDMA_MAX_CHANNELS..2*CPDMA_MAX_CHANNELS-1 for rx channels. However,
the rx and tx teardown registers expect zero based channel numbering.

Since the upper bits of the registers are reserved, the teardown also
worked before, this patch is cleanup only.

Signed-off-by: Christian Riesch <christian.riesch-3mrvs1K0uXizZXS1Dc/lvw@public.gmane.org>
---
 drivers/net/ethernet/ti/davinci_cpdma.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ethernet/ti/davinci_cpdma.c b/drivers/net/ethernet/ti/davinci_cpdma.c
index c97d2f5..3455876 100644
--- a/drivers/net/ethernet/ti/davinci_cpdma.c
+++ b/drivers/net/ethernet/ti/davinci_cpdma.c
@@ -822,7 +822,7 @@ int cpdma_chan_stop(struct cpdma_chan *chan)
 	dma_reg_write(ctlr, chan->int_clear, chan->mask);
 
 	/* trigger teardown */
-	dma_reg_write(ctlr, chan->td, chan->chan_num);
+	dma_reg_write(ctlr, chan->td, chan_linear(chan));
 
 	/* wait for teardown complete */
 	timeout = jiffies + HZ/10;	/* 100 msec */
-- 
1.7.0.4
