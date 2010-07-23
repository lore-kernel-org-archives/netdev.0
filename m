From: Andy Shevchenko <andy.shevchenko@gmail.com>
Subject: [PATCH 5/5] net: core: don't use own hex_to_bin() method
Date: Fri, 23 Jul 2010 16:18:10 +0300
Message-ID: <2519848e90eac1857ff7a8399e118980dd0bfbd0.1279890832.git.andy.shevchenko@gmail.com>
References: <cover.1279890832.git.andy.shevchenko@gmail.com>
Cc: Andy Shevchenko <andy.shevchenko@gmail.com>
To: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1279890832.git.andy.shevchenko@gmail.com>
In-Reply-To: <cover.1279890832.git.andy.shevchenko@gmail.com>
References: <cover.1279890832.git.andy.shevchenko@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Andy Shevchenko <andy.shevchenko@gmail.com>
---
 net/core/pktgen.c |   36 ++++++++++++------------------------
 1 files changed, 12 insertions(+), 24 deletions(-)

diff --git a/net/core/pktgen.c b/net/core/pktgen.c
index 24a19de..10a1ea7 100644
--- a/net/core/pktgen.c
+++ b/net/core/pktgen.c
@@ -1434,18 +1434,12 @@ static ssize_t pktgen_if_write(struct file *file,
 		i += len;
 
 		for (*m = 0; *v && m < pkt_dev->dst_mac + 6; v++) {
-			if (*v >= '0' && *v <= '9') {
-				*m *= 16;
-				*m += *v - '0';
-			}
-			if (*v >= 'A' && *v <= 'F') {
-				*m *= 16;
-				*m += *v - 'A' + 10;
-			}
-			if (*v >= 'a' && *v <= 'f') {
-				*m *= 16;
-				*m += *v - 'a' + 10;
-			}
+			int value;
+
+			value = hex_to_bin(*v);
+			if (value >= 0)
+				*m = *m * 16 + value;
+
 			if (*v == ':') {
 				m++;
 				*m = 0;
@@ -1476,18 +1470,12 @@ static ssize_t pktgen_if_write(struct file *file,
 		i += len;
 
 		for (*m = 0; *v && m < pkt_dev->src_mac + 6; v++) {
-			if (*v >= '0' && *v <= '9') {
-				*m *= 16;
-				*m += *v - '0';
-			}
-			if (*v >= 'A' && *v <= 'F') {
-				*m *= 16;
-				*m += *v - 'A' + 10;
-			}
-			if (*v >= 'a' && *v <= 'f') {
-				*m *= 16;
-				*m += *v - 'a' + 10;
-			}
+			int value;
+
+			value = hex_to_bin(*v);
+			if (value >= 0)
+				*m = *m * 16 + value;
+
 			if (*v == ':') {
 				m++;
 				*m = 0;
-- 
1.7.1.1
