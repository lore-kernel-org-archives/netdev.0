From: Hannes Eder <hannes@hanneseder.net>
Subject: [PATCH 42/43] drivers/net/wireless/ipw2x00: fix sparse warnings: fix
	signedness
Date: Sat, 14 Feb 2009 22:50:26 +0100
Message-ID: <20090214215013.24377.69151.stgit@vmbox.hanneseder.net>
References: <20090214210940.23489.95001.stgit@vmbox.hanneseder.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: kernel-janitors@vger.kernel.org, linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f25.google.com ([209.85.220.25]:51560 "EHLO
	mail-fx0-f25.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755625AbZBNVub (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 14 Feb 2009 16:50:31 -0500
In-Reply-To: <20090214210940.23489.95001.stgit@vmbox.hanneseder.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fix this sparse warnings:
  drivers/net/wireless/ipw2x00/ipw2100.c:1930:43: warning: incorrect type in argument 4 (different signedness)
  drivers/net/wireless/ipw2x00/ipw2100.c:1938:76: warning: incorrect type in argument 4 (different signedness)
  drivers/net/wireless/ipw2x00/ipw2100.c:1946:67: warning: incorrect type in argument 4 (different signedness)
  drivers/net/wireless/ipw2x00/ipw2100.c:1953:72: warning: incorrect type in argument 4 (different signedness)
  drivers/net/wireless/ipw2x00/ipw2100.c:4071:73: warning: incorrect type in argument 4 (different signedness)
  drivers/net/wireless/ipw2x00/ipw2100.c:4078:43: warning: incorrect type in argument 4 (different signedness)
  drivers/net/wireless/ipw2x00/ipw2100.c:4084:67: warning: incorrect type in argument 4 (different signedness)
  drivers/net/wireless/ipw2x00/ipw2100.c:7141:73: warning: incorrect type in argument 4 (different signedness)
  drivers/net/wireless/ipw2x00/ipw2100.c:8317:48: warning: incorrect type in argument 4 (different signedness)

Signed-off-by: Hannes Eder <hannes@hanneseder.net>
---
 drivers/net/wireless/ipw2x00/ipw2100.c |    9 +++++----
 1 files changed, 5 insertions(+), 4 deletions(-)

diff --git a/drivers/net/wireless/ipw2x00/ipw2100.c b/drivers/net/wireless/ipw2x00/ipw2100.c
index 9170c23..fc6a0b3 100644
--- a/drivers/net/wireless/ipw2x00/ipw2100.c
+++ b/drivers/net/wireless/ipw2x00/ipw2100.c
@@ -1910,7 +1910,8 @@ static void isr_indicate_associated(struct ipw2100_priv *priv, u32 status)
 {
 
 #define MAC_ASSOCIATION_READ_DELAY (HZ)
-	int ret, len, essid_len;
+	int ret;
+	unsigned int len, essid_len;
 	char essid[IW_ESSID_MAX_SIZE];
 	u32 txrate;
 	u32 chan;
@@ -4058,7 +4059,7 @@ static ssize_t show_bssinfo(struct device *d, struct device_attribute *attr,
 	u8 bssid[ETH_ALEN];
 	u32 chan = 0;
 	char *out = buf;
-	int length;
+	unsigned int length;
 	int ret;
 
 	if (priv->status & STATUS_RF_KILL_MASK)
@@ -7122,7 +7123,7 @@ static int ipw2100_wx_get_rate(struct net_device *dev,
 {
 	struct ipw2100_priv *priv = ieee80211_priv(dev);
 	int val;
-	int len = sizeof(val);
+	unsigned int len = sizeof(val);
 	int err = 0;
 
 	if (!(priv->status & STATUS_ENABLED) ||
@@ -8297,7 +8298,7 @@ static void ipw2100_wx_event_work(struct work_struct *work)
 	struct ipw2100_priv *priv =
 		container_of(work, struct ipw2100_priv, wx_event_work.work);
 	union iwreq_data wrqu;
-	int len = ETH_ALEN;
+	unsigned int len = ETH_ALEN;
 
 	if (priv->status & STATUS_STOPPING)
 		return;

