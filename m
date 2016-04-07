From: John Crispin <blogic-p3rKhJxN3npAfugRpC6u6w@public.gmane.org>
Subject: [PATCH V2 0/8] net: mediatek: make the driver pass stress tests
Date: Thu,  7 Apr 2016 21:26:42 +0200
Message-ID: <1460057210-55786-1-git-send-email-blogic@openwrt.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Felix Fietkau <nbd-p3rKhJxN3npAfugRpC6u6w@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
 =?UTF-8?q?Sean=20Wang=20=28=E7=8E=8B=E5=BF=97=E4=BA=98=29?=
 <sean.wang-NuS5LvNUpcJWk0Htik3J/w@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
 linux-mediatek-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org, Matthias Brugger <matthias.bgg-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
 John Crispin <blogic-p3rKhJxN3npAfugRpC6u6w@public.gmane.org>
To: "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <linux-mediatek-bounces+glpam-linux-mediatek=m.gmane.org-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org>
List-Unsubscribe: <http://lists.infradead.org/mailman/options/linux-mediatek>,
 <mailto:linux-mediatek-request-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.infradead.org/pipermail/linux-mediatek/>
List-Post: <mailto:linux-mediatek-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org>
List-Help: <mailto:linux-mediatek-request-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org?subject=help>
List-Subscribe: <http://lists.infradead.org/mailman/listinfo/linux-mediatek>,
 <mailto:linux-mediatek-request-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org?subject=subscribe>
Sender: "Linux-mediatek" <linux-mediatek-bounces-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org>
Errors-To: linux-mediatek-bounces+glpam-linux-mediatek=m.gmane.org-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org
List-Id: netdev.vger.kernel.org

While testing the driver we managed to get the TX path to stall and fail
to recover. When dual MAC support was added to the driver, the whole queue
stop/wake code was not properly adapted. There was also a regression in the
locking of the xmit function. The fact that watchdog_timeo was not set and
that the tx_timeout code failed to properly reset the dma, irq and queue
just made the mess complete.

This series make the driver pass stress testing. With this series applied
the testbed has been running for several days and still has not locked up.
We have a second setup that has a small hack patch applied to randomly stop
irqs and/or one of the queues and successfully manages to recover from these
simulated tx stalls.

John Crispin (8):
  net: mediatek: watchdog_timeo was not set
  net: mediatek: mtk_cal_txd_req() returns bad value
  net: mediatek: remove superfluous reset call
  net: mediatek: fix stop and wakeup of queue
  net: mediatek: fix mtk_pending_work
  net: mediatek: fix TX locking
  net: mediatek: move the pending_work struct to the device generic
    struct
  net: mediatek: do not set the QID field in the TX DMA descriptors

 drivers/net/ethernet/mediatek/mtk_eth_soc.c |  106 ++++++++++++++++-----------
 drivers/net/ethernet/mediatek/mtk_eth_soc.h |    4 +-
 2 files changed, 66 insertions(+), 44 deletions(-)

-- 
1.7.10.4
