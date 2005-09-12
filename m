From: "John W. Linville" <linville@tuxdriver.com>
Subject: [patch 2.6.13 5/5] tg3: correct rx_dropped and add rx_missed_errors
Date: Mon, 12 Sep 2005 10:49:00 -0400
Message-ID: <09122005104900.650@bilbo.tuxdriver.com>
References: <09122005104900.585@bilbo.tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: mchan@broadcom.com, davem@davemloft.net, jgarzik@pobox.com
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1751384AbVILPBp@vger.kernel.org>
To: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
In-Reply-To: <09122005104900.585@bilbo.tuxdriver.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Do not count non-error frames dropped by the hardware as
rx_errors. Instead, count them as part of rx_missed_errors.

Signed-off-by: John W. Linville <linville@tuxdriver.com>
---

 drivers/net/tg3.c |    6 ++++--
 1 files changed, 4 insertions(+), 2 deletions(-)

diff --git a/drivers/net/tg3.c b/drivers/net/tg3.c
--- a/drivers/net/tg3.c
+++ b/drivers/net/tg3.c
@@ -6893,8 +6893,7 @@ static struct net_device_stats *tg3_get_
 		get_stat64(&hw_stats->tx_octets);
 
 	stats->rx_errors = old_stats->rx_errors +
-		get_stat64(&hw_stats->rx_errors) +
-		get_stat64(&hw_stats->rx_discards);
+		get_stat64(&hw_stats->rx_errors);
 	stats->tx_errors = old_stats->tx_errors +
 		get_stat64(&hw_stats->tx_errors) +
 		get_stat64(&hw_stats->tx_mac_errors) +
@@ -6922,6 +6921,9 @@ static struct net_device_stats *tg3_get_
 	stats->rx_crc_errors = old_stats->rx_crc_errors +
 		calc_crc_errors(tp);
 
+	stats->rx_missed_errors = old_stats->rx_missed_errors +
+		get_stat64(&hw_stats->rx_discards);
+
 	return stats;
 }
 
