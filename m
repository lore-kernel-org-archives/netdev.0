From: mabbas <mabbas@linux.intel.com>
Subject: Re: [d80211 patch 1/1] setting bss freq and phymode using rx_status
Date: Mon, 25 Sep 2006 10:15:28 -0700
Message-ID: <45180EB0.1060204@linux.intel.com>
References: <44F356DF.9000000@linux.intel.com>	<20060921190126.4d884c44@logostar.upir.cz>	<1158865436.27546.23.camel@localhost.localdomain>	<4512EC5C.1030807@linux.intel.com>	<1158870634.5769.21.camel@localhost.localdomain>	<4512F876.7000203@linux.intel.com>	<20060922003844.6817f22b@logostar.upir.cz>	<20060921225514.GA26850@bougret.hpl.hp.com>	<20060922004235.GA7322@instant802.com>	<20060922005743.GB27052@bougret.hpl.hp.com>	<451463D6.4070309@linux.intel.com> <20060925181643.1621489a@griffin.suse.cz>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------050003070009060001030506"
Cc: Jiri Benc <jbenc@suse.cz>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga05.intel.com ([192.55.52.89]:28526 "EHLO
	fmsmga101.fm.intel.com") by vger.kernel.org with ESMTP
	id S1751318AbWIYRRR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 25 Sep 2006 13:17:17 -0400
To: netdev@vger.kernel.org
In-Reply-To: <20060925181643.1621489a@griffin.suse.cz>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------050003070009060001030506
Content-Type: text/plain; charset=US-ASCII; format=flowed
Content-Transfer-Encoding: 7bit

actaully we dont even need local->conf.channel. rx_status->channel holds 
the channel
we physically received the frame on. channel hold the value from ds. if 
they are not equal then
adjust freq. Attached is the modified patch



--------------050003070009060001030506
Content-Type: text/x-patch;
 name="d80211-iwlist-fix-freq-mode.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="d80211-iwlist-fix-freq-mode.patch"


Signed-off-by: Mohamed Abbas <mabbas@linux.intel.com>

diff --git a/net/d80211/ieee80211_sta.c b/net/d80211/ieee80211_sta.c
index a933d92..a0746b9 100644
--- a/net/d80211/ieee80211_sta.c
+++ b/net/d80211/ieee80211_sta.c
@@ -1539,12 +1539,12 @@ #endif
 	}
 
 
-	bss->hw_mode = local->conf.phymode;
+	bss->hw_mode = rx_status->phymode;
 	bss->channel = channel;
-	bss->freq = local->conf.freq;
-	if (channel != local->conf.channel &&
-	    (local->conf.phymode == MODE_IEEE80211G ||
-	     local->conf.phymode == MODE_IEEE80211B) &&
+	bss->freq = rx_status->freq;
+	if (channel != rx_status->channel &&
+	    (bss->hw_mode == MODE_IEEE80211G ||
+	     bss->hw_mode == MODE_IEEE80211B) &&
 	    channel >= 1 && channel <= 14) {
 		static const int freq_list[] = {
 			2412, 2417, 2422, 2427, 2432, 2437, 2442,

--------------050003070009060001030506--
