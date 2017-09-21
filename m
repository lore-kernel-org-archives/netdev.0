From: Allen Pais <allen.lkml@gmail.com>
Subject: [PATCH 35/64] drivers: net: can: usb: use setup_timer() helper.
Date: Thu, 21 Sep 2017 22:34:56 +0530
Message-ID: <1506013525-29291-36-git-send-email-allen.lkml@gmail.com>
References: <1506013525-29291-1-git-send-email-allen.lkml@gmail.com>
Cc: linux-kernel@vger.kernel.org, m.grzeschik@pengutronix.de,
        dmitry.tarnyagin@lockless.no, wg@grandegger.com,
        mkl@pengutronix.de, mark.einon@gmail.com, linux@armlinux.org.uk,
        pcnet32@frontier.com, f.fainelli@gmail.com,
        bcm-kernel-feedback-list@broadcom.com, venza@brownhat.org,
        ajk@comnets.uni-bremen.de, jes@trained-monkey.org,
        romieu@fr.zoreil.com, khc@pm.waw.pl, simon@thekelleys.org.uk,
        davem@davemloft.net, linux-can@vger.kernel.org,
        adi-buildroot-devel@lists.sourceforge.net,
        Allen Pais <allen.lkml@gmail.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1506013525-29291-1-git-send-email-allen.lkml@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

    Use setup_timer function instead of initializing timer with the
    function and data fields.

Signed-off-by: Allen Pais <allen.lkml@gmail.com>
---
 drivers/net/can/usb/peak_usb/pcan_usb.c | 5 ++---
 1 file changed, 2 insertions(+), 3 deletions(-)

diff --git a/drivers/net/can/usb/peak_usb/pcan_usb.c b/drivers/net/can/usb/peak_usb/pcan_usb.c
index 838545c..7e10dbd 100644
--- a/drivers/net/can/usb/peak_usb/pcan_usb.c
+++ b/drivers/net/can/usb/peak_usb/pcan_usb.c
@@ -798,9 +798,8 @@ static int pcan_usb_init(struct peak_usb_device *dev)
 	int err;
 
 	/* initialize a timer needed to wait for hardware restart */
-	init_timer(&pdev->restart_timer);
-	pdev->restart_timer.function = pcan_usb_restart;
-	pdev->restart_timer.data = (unsigned long)dev;
+	setup_timer(&pdev->restart_timer, pcan_usb_restart,
+		    (unsigned long)dev);
 
 	/*
 	 * explicit use of dev_xxx() instead of netdev_xxx() here:
-- 
2.7.4
