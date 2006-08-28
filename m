From: mabbas <mabbas@linux.intel.com>
Subject: [PATCH 6/7] d80211: diplay supported rates in readable format
Date: Mon, 28 Aug 2006 13:52:06 -0700
Message-ID: <44F35776.7060800@linux.intel.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------080102070808030509030405"
Cc: jbenc@suse.cz
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga07.intel.com ([143.182.124.22]:34467 "EHLO
	azsmga101.ch.intel.com") by vger.kernel.org with ESMTP
	id S932123AbWH1Uvs (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 28 Aug 2006 16:51:48 -0400
To: netdev@vger.kernel.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------080102070808030509030405
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit



--------------080102070808030509030405
Content-Type: text/x-patch;
 name="d80211-iwlist-display.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="d80211-iwlist-display.patch"

This patch modify d80211 to report supported rates in readable
format in iwlist scan command.

Signed-off-by: Mohamed Abbas <mabbas@linux.intel.com>

diff --git a/net/d80211/ieee80211_sta.c b/net/d80211/ieee80211_sta.c
index a933d92..b2e45a4 100644
--- a/net/d80211/ieee80211_sta.c
+++ b/net/d80211/ieee80211_sta.c
@@ -2714,15 +2714,21 @@ ieee80211_sta_scan_result(struct net_dev
 		current_ev = iwe_stream_add_point(current_ev, end_buf, &iwe,
 						  buf);
 
-		p = buf;
-		p += sprintf(p, "supp_rates=");
-		for (i = 0; i < bss->supp_rates_len; i++)
-			p+= sprintf(p, "%02x", bss->supp_rates[i]);
-		memset(&iwe, 0, sizeof(iwe));
-		iwe.cmd = IWEVCUSTOM;
-		iwe.u.data.length = strlen(buf);
-		current_ev = iwe_stream_add_point(current_ev, end_buf, &iwe,
-						  buf);
+		/* dispaly all support rates in readable format */
+		p = current_ev + IW_EV_LCP_LEN;
+		iwe.cmd = SIOCGIWRATE;
+		/* Those two flags are ignored... */
+		iwe.u.bitrate.fixed = iwe.u.bitrate.disabled = 0;
+
+		for (i = 0; i < bss->supp_rates_len; i++) {
+			iwe.u.bitrate.value = ((bss->supp_rates[i] & 
+							0x7f) * 500000);
+			p = iwe_stream_add_value(current_ev, p, 
+					end_buf, &iwe, IW_EV_PARAM_LEN);
+		}
+		/* Check if we added any rate */
+		if((p - current_ev) > IW_EV_LCP_LEN)
+			current_ev = p;
 
 		kfree(buf);
 		break;

--------------080102070808030509030405--
