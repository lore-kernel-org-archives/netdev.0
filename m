From: mabbas <mabbas@linux.intel.com>
Subject: [PATCH 5/7] d80211: indicate if unassociate/radio off status
Date: Mon, 28 Aug 2006 13:49:35 -0700
Message-ID: <44F356DF.9000000@linux.intel.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------050003030705030506010809"
Cc: jbenc@suse.cz
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga06.intel.com ([134.134.136.21]:61305 "EHLO
	orsmga101.jf.intel.com") by vger.kernel.org with ESMTP
	id S932090AbWH1UtT (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 28 Aug 2006 16:49:19 -0400
To: netdev@vger.kernel.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------050003030705030506010809
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit



--------------050003030705030506010809
Content-Type: text/x-patch;
 name="d80211-wname.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="d80211-wname.patch"


This patch indicate unassociated and radio off status
in name field

Signed-off-by: Mohamed Abbas <mabbas@linux.intel.com>

diff --git a/net/d80211/ieee80211_ioctl.c b/net/d80211/ieee80211_ioctl.c
index 89a58e3..44b2698 100644
--- a/net/d80211/ieee80211_ioctl.c
+++ b/net/d80211/ieee80211_ioctl.c
@@ -1538,6 +1538,19 @@ static int ieee80211_ioctl_giwname(struc
 				   char *name, char *extra)
 {
 	struct ieee80211_local *local = dev->ieee80211_ptr;
+	struct ieee80211_sub_if_data *sdata;
+
+	sdata = IEEE80211_DEV_TO_SUB_IF(dev);
+	if (!local->conf.radio_enabled) {
+        	strcpy(name, "radio off");
+                return 0;
+	} else if (sdata->type == IEEE80211_IF_TYPE_STA) {
+		if ((sdata->u.sta.state != IEEE80211_ASSOCIATED) ||
+		    (sdata->u.sta.probereq_poll)) {
+			strcpy(name, "unassociated");
+			return 0;
+		}
+	}
 
 	switch (local->conf.phymode) {
 	case MODE_IEEE80211A:

--------------050003030705030506010809--
