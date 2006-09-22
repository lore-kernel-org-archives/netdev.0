From: mabbas <mabbas@linux.intel.com>
Subject: [d80211 patch 1/1] setting bss freq and phymode using rx_status
Date: Fri, 22 Sep 2006 15:29:42 -0700
Message-ID: <451463D6.4070309@linux.intel.com>
References: <44F356DF.9000000@linux.intel.com> <20060921190126.4d884c44@logostar.upir.cz> <1158865436.27546.23.camel@localhost.localdomain> <4512EC5C.1030807@linux.intel.com> <1158870634.5769.21.camel@localhost.localdomain> <4512F876.7000203@linux.intel.com> <20060922003844.6817f22b@logostar.upir.cz> <20060921225514.GA26850@bougret.hpl.hp.com> <20060922004235.GA7322@instant802.com> <20060922005743.GB27052@bougret.hpl.hp.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------030303090108040200090207"
Cc: Jiri Benc <jbenc@suse.cz>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga05.intel.com ([192.55.52.89]:20129 "EHLO
	fmsmga101.fm.intel.com") by vger.kernel.org with ESMTP
	id S965238AbWIVW3h (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 22 Sep 2006 18:29:37 -0400
To: netdev@vger.kernel.org
In-Reply-To: <20060922005743.GB27052@bougret.hpl.hp.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------030303090108040200090207
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit

this patch is a replacement for d80211-iwlist-fix.patch. Now we
set bss's phymode and freq using rx_status. The low level driver need to
set these values.

--------------030303090108040200090207
Content-Type: text/x-patch;
 name="d80211-iwlist-fix-freq-mode.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="d80211-iwlist-fix-freq-mode.patch"


Signed-off-by: Mohamed Abbas <mabbas@linux.intel.com>

diff --git a/net/d80211/ieee80211_sta.c b/net/d80211/ieee80211_sta.c
index a933d92..ddbaf14 100644
--- a/net/d80211/ieee80211_sta.c
+++ b/net/d80211/ieee80211_sta.c
@@ -1539,9 +1539,9 @@ #endif
 	}
 
 
-	bss->hw_mode = local->conf.phymode;
+	bss->hw_mode = rx_status->phymode;
 	bss->channel = channel;
-	bss->freq = local->conf.freq;
+	bss->freq = rx_status->freq;
 	if (channel != local->conf.channel &&
 	    (local->conf.phymode == MODE_IEEE80211G ||
 	     local->conf.phymode == MODE_IEEE80211B) &&

--------------030303090108040200090207--
