From: Allen Pais <allen.lkml@gmail.com>
Subject: [PATCH 1/1] net: wan : hdlc: use setup_timer() helper
Date: Thu, 21 Sep 2017 18:17:55 +0530
Message-ID: <1505998075-12969-1-git-send-email-allen.lkml@gmail.com>
Cc: khc@pm.waw.pl, netdev@vger.kernel.org,
        Allen Pais <allen.lkml@gmail.com>
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

    Use setup_timer function instead of initializing timer with the
    function and data fields.

Signed-off-by: Allen Pais <allen.lkml@gmail.com>
---
 drivers/net/wan/hdlc_fr.c | 5 ++---
 1 file changed, 2 insertions(+), 3 deletions(-)

diff --git a/drivers/net/wan/hdlc_fr.c b/drivers/net/wan/hdlc_fr.c
index 78596e4..425a47f 100644
--- a/drivers/net/wan/hdlc_fr.c
+++ b/drivers/net/wan/hdlc_fr.c
@@ -1003,11 +1003,10 @@ static void fr_start(struct net_device *dev)
 		state(hdlc)->n391cnt = 0;
 		state(hdlc)->txseq = state(hdlc)->rxseq = 0;
 
-		init_timer(&state(hdlc)->timer);
+		setup_timer(&state(hdlc)->timer, fr_timer,
+			    (unsigned long)dev);
 		/* First poll after 1 s */
 		state(hdlc)->timer.expires = jiffies + HZ;
-		state(hdlc)->timer.function = fr_timer;
-		state(hdlc)->timer.data = (unsigned long)dev;
 		add_timer(&state(hdlc)->timer);
 	} else
 		fr_set_link_state(1, dev);
-- 
2.7.4
