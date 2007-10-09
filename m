From: Mark Brown <broonie@sirena.org.uk>
Subject: [PATCH] natsemi: Use NATSEMI_TIMER_FREQ consistently
Date: Tue,  9 Oct 2007 22:57:39 +0100
Message-ID: <1191967059-7143-2-git-send-email-broonie@sirena.org.uk>
References: <1191967059-7143-1-git-send-email-broonie@sirena.org.uk>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Mark Brown <broonie@sirena.org.uk>
To: jgarzik@pobox.com, thockin@hockin.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1755990AbXJIWp2@vger.kernel.org>
In-Reply-To: <1191967059-7143-1-git-send-email-broonie@sirena.org.uk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The natsemi driver has a define NATSEMI_TIMER_FREQ which looks like it
controls the normal frequency of the chip poll timer but in fact only
takes effect for the first run of the timer.  Adjust the value of the
define to match that used by the timer and use the define consistently.

Signed-off-by: Mark Brown <broonie@sirena.org.uk>
---
 drivers/net/natsemi.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/natsemi.c b/drivers/net/natsemi.c
index 0b33a58..1f88604 100644
--- a/drivers/net/natsemi.c
+++ b/drivers/net/natsemi.c
@@ -108,7 +108,7 @@ static int full_duplex[MAX_UNITS];
 #define TX_TIMEOUT  (2*HZ)
 
 #define NATSEMI_HW_TIMEOUT	400
-#define NATSEMI_TIMER_FREQ	3*HZ
+#define NATSEMI_TIMER_FREQ	5*HZ
 #define NATSEMI_PG0_NREGS	64
 #define NATSEMI_RFDR_NREGS	8
 #define NATSEMI_PG1_NREGS	4
@@ -1797,7 +1797,7 @@ static void netdev_timer(unsigned long data)
 	struct net_device *dev = (struct net_device *)data;
 	struct netdev_private *np = netdev_priv(dev);
 	void __iomem * ioaddr = ns_ioaddr(dev);
-	int next_tick = 5*HZ;
+	int next_tick = NATSEMI_TIMER_FREQ;
 
 	if (netif_msg_timer(np)) {
 		/* DO NOT read the IntrStatus register,
-- 
1.5.3.4
