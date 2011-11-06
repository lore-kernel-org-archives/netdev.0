From: Julia Lawall <julia@diku.dk>
Subject: [PATCH 1/5] net/batman-adv: use kstrtoul, etc
Date: Sun,  6 Nov 2011 14:26:46 +0100
Message-ID: <1320586010-21931-2-git-send-email-julia@diku.dk>
References: <1320586010-21931-1-git-send-email-julia@diku.dk>
Cc: kernel-janitors@vger.kernel.org,
	Simon Wunderlich <siwu@hrz.tu-chemnitz.de>,
	"David S. Miller" <davem@davemloft.net>,
	b.a.t.m.a.n@lists.open-mesh.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Marek Lindner <lindner_marek@yahoo.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1320586010-21931-1-git-send-email-julia@diku.dk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Julia Lawall <julia@diku.dk>

Use kstrtoul, etc instead of the now deprecated strict_strtoul, etc.

A semantic patch rule for the kstrtoul case is as follows:
(http://coccinelle.lip6.fr/)

// <smpl>
@@
expression a,b;
{int,long} *c;
@@

-strict_strtoul
+kstrtoul
 (a,b,c)
// </smpl>

Signed-off-by: Julia Lawall <julia@diku.dk>

---
 net/batman-adv/bat_sysfs.c      |    4 ++--
 net/batman-adv/gateway_common.c |    4 ++--
 2 files changed, 4 insertions(+), 4 deletions(-)

diff -u -p a/net/batman-adv/bat_sysfs.c b/net/batman-adv/bat_sysfs.c
--- a/net/batman-adv/bat_sysfs.c
+++ b/net/batman-adv/bat_sysfs.c
@@ -174,7 +174,7 @@ static int store_uint_attr(const char *b
 	unsigned long uint_val;
 	int ret;
 
-	ret = strict_strtoul(buff, 10, &uint_val);
+	ret = kstrtoul(buff, 10, &uint_val);
 	if (ret) {
 		bat_info(net_dev,
 			 "%s: Invalid parameter received: %s\n",
@@ -239,7 +239,7 @@ static ssize_t store_vis_mode(struct kob
 	unsigned long val;
 	int ret, vis_mode_tmp = -1;
 
-	ret = strict_strtoul(buff, 10, &val);
+	ret = kstrtoul(buff, 10, &val);
 
 	if (((count == 2) && (!ret) && (val == VIS_TYPE_CLIENT_UPDATE)) ||
 	    (strncmp(buff, "client", 6) == 0) ||
diff -u -p a/net/batman-adv/gateway_common.c b/net/batman-adv/gateway_common.c
--- a/net/batman-adv/gateway_common.c
+++ b/net/batman-adv/gateway_common.c
@@ -97,7 +97,7 @@ static bool parse_gw_bandwidth(struct ne
 			*tmp_ptr = '\0';
 	}
 
-	ret = strict_strtol(buff, 10, &ldown);
+	ret = kstrtol(buff, 10, &ldown);
 	if (ret) {
 		bat_err(net_dev,
 			"Download speed of gateway mode invalid: %s\n",
@@ -122,7 +122,7 @@ static bool parse_gw_bandwidth(struct ne
 				*tmp_ptr = '\0';
 		}
 
-		ret = strict_strtol(slash_ptr + 1, 10, &lup);
+		ret = kstrtol(slash_ptr + 1, 10, &lup);
 		if (ret) {
 			bat_err(net_dev,
 				"Upload speed of gateway mode invalid: "
