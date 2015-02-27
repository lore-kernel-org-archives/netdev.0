From: Joe Perches <joe@perches.com>
Subject: [PATCH net-next] wireless: test sscanf return values
Date: Thu, 26 Feb 2015 21:43:11 -0800
Message-ID: <1425015791.2690.7.camel@perches.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	LKML <linux-kernel@vger.kernel.org>
To: Johannes Berg <johannes@sipsolutions.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

At some point, it'd be good to make sscanf use __must_check
so make sure the net/ uses of sscanf use the return value.

Signed-off-by: Joe Perches <joe@perches.com>
---

Compiled, untested.

 net/mac80211/debugfs.c | 4 ++--
 net/wireless/core.c    | 4 ++--
 2 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/net/mac80211/debugfs.c b/net/mac80211/debugfs.c
index eeb0bbd..0e44be7 100644
--- a/net/mac80211/debugfs.c
+++ b/net/mac80211/debugfs.c
@@ -160,9 +160,9 @@ static ssize_t sta_tx_latency_stat_write(struct file *file,
 	tx_latency->n_ranges = n_ranges;
 	for (i = 0; i < n_ranges; i++) { /* setting bin ranges */
 		token = strsep(&bins, TX_LATENCY_BIN_DELIMTER_S);
-		sscanf(token, "%d", &tx_latency->ranges[i]);
 		/* bins values should be in ascending order */
-		if (prev_bin >= tx_latency->ranges[i]) {
+		if (sscanf(token, "%d", &tx_latency->ranges[i]) != 1 ||
+		    prev_bin >= tx_latency->ranges[i]) {
 			ret = -EINVAL;
 			kfree(tx_latency);
 			goto unlock;
diff --git a/net/wireless/core.c b/net/wireless/core.c
index 3af0ecf..69a350e 100644
--- a/net/wireless/core.c
+++ b/net/wireless/core.c
@@ -95,8 +95,8 @@ static int cfg80211_dev_check_name(struct cfg80211_registered_device *rdev,
 	ASSERT_RTNL();
 
 	/* prohibit calling the thing phy%d when %d is not its number */
-	sscanf(newname, PHY_NAME "%d%n", &wiphy_idx, &taken);
-	if (taken == strlen(newname) && wiphy_idx != rdev->wiphy_idx) {
+	if (sscanf(newname, PHY_NAME "%d%n", &wiphy_idx, &taken) == 1 &&
+	    taken == strlen(newname) && wiphy_idx != rdev->wiphy_idx) {
 		/* count number of places needed to print wiphy_idx */
 		digits = 1;
 		while (wiphy_idx /= 10)
