From: Ivo van Doorn <ivdoorn@gmail.com>
Subject: [PATCH] d80211: Reset assoc and auth retry counters
Date: Tue, 28 Nov 2006 20:56:05 +0100
Message-ID: <200611282056.05641.IvDoorn@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nf-out-0910.google.com ([64.233.182.187]:29468 "EHLO
	nf-out-0910.google.com") by vger.kernel.org with ESMTP
	id S936075AbWK1T4S (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 28 Nov 2006 14:56:18 -0500
Received: by nf-out-0910.google.com with SMTP id o25so2672835nfa
        for <netdev@vger.kernel.org>; Tue, 28 Nov 2006 11:56:17 -0800 (PST)
To: "John Linville" <linville@tuxdriver.com>, Jiri Benc <jbenc@suse.cz>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

After a succesfull authentication and association the matching retry counter
must be reset to 0.
Failure to do so will result in failure to authenticate after the interface
has been deauthenticated. This does not always happen after the first
deauthentication, but after the interface has been several times been
deauthenticated it will refuse to authenticate.

Signed-off-by Ivo van Doorn <IvDoorn@gmail.com>

---

diff --git a/net/d80211/ieee80211_sta.c b/net/d80211/ieee80211_sta.c
index deebbc7..04bd5cd 100644
--- a/net/d80211/ieee80211_sta.c
+++ b/net/d80211/ieee80211_sta.c
@@ -694,6 +694,7 @@ static void ieee80211_associated(struct
 	/* TODO: remove expired BSSes */
 
 	ifsta->state = IEEE80211_ASSOCIATED;
+	ifsta->assoc_tries = 0;
 
 	sta = sta_info_get(local, ifsta->bssid);
 	if (!sta) {
@@ -821,6 +822,7 @@ static void ieee80211_auth_completed(str
 {
 	printk(KERN_DEBUG "%s: authenticated\n", dev->name);
 	ifsta->authenticated = 1;
+	ifsta->auth_tries = 0;
 	ieee80211_associate(dev, ifsta);
 }
 
