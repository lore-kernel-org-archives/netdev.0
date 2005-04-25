From: "Michael Chan" <mchan@broadcom.com>
Subject: [PATCH 2.6.12-rc2 2/3] tg3: Refresh hw index in tg3_rx()
Date: Mon, 25 Apr 2005 14:09:11 -0700
Message-ID: <1114463351.4917.39.camel@rh4>
References: <1114463061.4917.34.camel@rh4>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "Arthur Kepner" <akepner@sgi.com>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>
In-Reply-To: <1114463061.4917.34.camel@rh4>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This patch refreshes the hw rx producer in tg3_rx() so that additional
work posted by the hardware can be processed.

Signed-off-by: Michael Chan <mchan@broadcom.com>

diff -Nru c/drivers/net/tg3.c d/drivers/net/tg3.c
--- c/drivers/net/tg3.c	2005-04-25 12:32:44.000000000 -0700
+++ d/drivers/net/tg3.c	2005-04-25 12:39:46.000000000 -0700
@@ -2802,6 +2802,12 @@
 next_pkt_nopost:
 		sw_idx++;
 		sw_idx %= TG3_RX_RCB_RING_SIZE(tp);
+
+		/* Refresh hw_idx to see if there is new work */
+		if (sw_idx == hw_idx) {
+			hw_idx = tp->hw_status->idx[0].rx_producer;
+			rmb();
+		}
 	}
 
 	/* ACK the status ring. */
