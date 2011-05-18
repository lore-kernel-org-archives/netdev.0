From: David Decotigny <decot@google.com>
Subject: [PATCH] forcedeth: new ethtool stat "tx_timeout" to account for tx_timeouts
Date: Wed, 18 May 2011 14:09:05 -0700
Message-ID: <1305752945-14843-2-git-send-email-decot@google.com>
References: <1305752945-14843-1-git-send-email-decot@google.com>
Cc: kernel-net-upstream@google.com, Sameer Nanda <snanda@google.com>,
	David Decotigny <decot@google.com>
To: "David S. Miller" <davem@davemloft.net>,
	Joe Perches <joe@perches.com>,
	Szymon Janc <szymon@janc.net.pl>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1305752945-14843-1-git-send-email-decot@google.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Sameer Nanda <snanda@google.com>

This change publishes a new ethtool stats: tx_timeout that counts the
number of times the tx_timeout callback was triggered.


Signed-off-by: David Decotigny <decot@google.com>
---
 drivers/net/forcedeth.c |    4 ++++
 1 files changed, 4 insertions(+), 0 deletions(-)

diff --git a/drivers/net/forcedeth.c b/drivers/net/forcedeth.c
index 895471d..112dc0b 100644
--- a/drivers/net/forcedeth.c
+++ b/drivers/net/forcedeth.c
@@ -632,6 +632,7 @@ static const struct nv_ethtool_str nv_estats_str[] = {
 	{ "rx_packets" },
 	{ "rx_errors_total" },
 	{ "tx_errors_total" },
+	{ "tx_timeout" },
 
 	/* version 2 stats */
 	{ "tx_deferral" },
@@ -672,6 +673,7 @@ struct nv_ethtool_stats {
 	u64 rx_packets;
 	u64 rx_errors_total;
 	u64 tx_errors_total;
+	u64 tx_timeout;
 
 	/* version 2 stats */
 	u64 tx_deferral;
@@ -2526,6 +2528,8 @@ static void nv_tx_timeout(struct net_device *dev)
 
 	spin_lock_irq(&np->lock);
 
+	np->estats.tx_timeout++;
+
 	/* 1) stop tx engine */
 	nv_stop_tx(dev);
 
-- 
1.7.3.1
