From: Allen Pais <allen.lkml@gmail.com>
Subject: [PATCH 18/64] drivers: net: cisco_hdlc: use setup_timer() helper.
Date: Thu, 21 Sep 2017 22:34:39 +0530
Message-ID: <1506013525-29291-19-git-send-email-allen.lkml@gmail.com>
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
 drivers/net/wan/hdlc_cisco.c | 4 +---
 1 file changed, 1 insertion(+), 3 deletions(-)

diff --git a/drivers/net/wan/hdlc_cisco.c b/drivers/net/wan/hdlc_cisco.c
index a408abc..c696d42 100644
--- a/drivers/net/wan/hdlc_cisco.c
+++ b/drivers/net/wan/hdlc_cisco.c
@@ -293,10 +293,8 @@ static void cisco_start(struct net_device *dev)
 	st->up = st->txseq = st->rxseq = 0;
 	spin_unlock_irqrestore(&st->lock, flags);
 
-	init_timer(&st->timer);
+	setup_timer(&st->timer, cisco_timer, (unsigned long)dev);
 	st->timer.expires = jiffies + HZ; /* First poll after 1 s */
-	st->timer.function = cisco_timer;
-	st->timer.data = (unsigned long)dev;
 	add_timer(&st->timer);
 }
 
-- 
2.7.4
