From: Jason Lunz <lunz@falooley.org>
Subject: [PATCH] hush noisy ieee80211 CCMP printks
Date: Sun, 4 Jun 2006 20:12:09 -0400
Message-ID: <20060605001208.GA4585@opus.vpn-dev.reflex>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.reflexsecurity.com ([72.54.64.74]:13016 "EHLO
	crown.reflexsecurity.com") by vger.kernel.org with ESMTP
	id S932345AbWFEALL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 4 Jun 2006 20:11:11 -0400
To: jkmaline@cc.hut.fi, linville@tuxdriver.com
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Don't swamp syslog with
CCMP: decrypt failed: STA=00:12:17:3a:e2:c7
and 
CCMP: replay detected: STA=00:12:17:3a:e2:c7 previous PN 000000000004 received PN 000000000004
messages.

These both seem to be completely normal in regular use, especially
'decrypt failed' whenever another wpa-using station on the same AP is
within range.

These events are still being counted in the statistics.

Signed-off-by: Jason Lunz <lunz@falooley.org>

---
 net/ieee80211/ieee80211_crypt_ccmp.c |   11 -----------
 1 file changed, 11 deletions(-)

Index: linux-2.6.17-rc5-git11/net/ieee80211/ieee80211_crypt_ccmp.c
===================================================================
--- linux-2.6.17-rc5-git11.orig/net/ieee80211/ieee80211_crypt_ccmp.c
+++ linux-2.6.17-rc5-git11/net/ieee80211/ieee80211_crypt_ccmp.c
@@ -326,13 +326,6 @@
 	pos += 8;
 
 	if (memcmp(pn, key->rx_pn, CCMP_PN_LEN) <= 0) {
-		if (net_ratelimit()) {
-			printk(KERN_DEBUG "CCMP: replay detected: STA=" MAC_FMT
-			       " previous PN %02x%02x%02x%02x%02x%02x "
-			       "received PN %02x%02x%02x%02x%02x%02x\n",
-			       MAC_ARG(hdr->addr2), MAC_ARG(key->rx_pn),
-			       MAC_ARG(pn));
-		}
 		key->dot11RSNAStatsCCMPReplays++;
 		return -4;
 	}
@@ -357,10 +350,6 @@
 	}
 
 	if (memcmp(mic, a, CCMP_MIC_LEN) != 0) {
-		if (net_ratelimit()) {
-			printk(KERN_DEBUG "CCMP: decrypt failed: STA="
-			       MAC_FMT "\n", MAC_ARG(hdr->addr2));
-		}
 		key->dot11RSNAStatsCCMPDecryptErrors++;
 		return -5;
 	}


