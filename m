From: Joseph Jezak <josejx@gentoo.org>
Subject: [PATCH] SoftMAC: Add network to ieee80211softmac_call_events when
 associate times out
Date: Sun, 11 Jun 2006 12:01:03 -0400
Message-ID: <448C3E3F.7040908@gentoo.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Return-path: <netdev-owner@vger.kernel.org>
Received: from rwcrmhc12.comcast.net ([204.127.192.82]:63438 "EHLO
	rwcrmhc12.comcast.net") by vger.kernel.org with ESMTP
	id S1751168AbWFKQBF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 11 Jun 2006 12:01:05 -0400
To: NetDev <netdev@vger.kernel.org>, bcm43xx-dev@berlios.de
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The ieee80211softmac_call_events function, when called with event type
IEEE80211SOFTMAC_EVENT_ASSOCIATE_TIMEOUT should pass the network as the
third parameter.  This patch does that.

Signed-off-by: Joseph Jezak <josejx@gentoo.org>

---

diff --git a/net/ieee80211/softmac/ieee80211softmac_assoc.c b/net/ieee80211/softmac/ieee80211softmac_assoc.c
index aa65a7e..f9f7c8d 100644
--- a/net/ieee80211/softmac/ieee80211softmac_assoc.c
+++ b/net/ieee80211/softmac/ieee80211softmac_assoc.c
@@ -61,6 +61,7 @@ void
 ieee80211softmac_assoc_timeout(void *d)
 {
 	struct ieee80211softmac_device *mac = (struct ieee80211softmac_device *)d;
+	struct ieee80211softmac_network *n;
 	unsigned long flags;
 
 	spin_lock_irqsave(&mac->lock, flags);
@@ -73,11 +74,12 @@ ieee80211softmac_assoc_timeout(void *d)
 	mac->associnfo.associating = 0;
 	mac->associnfo.bssvalid = 0;
 	mac->associated = 0;
+
+	n = ieee80211softmac_get_network_by_bssid_locked(mac, mac->associnfo.bssid);	
 	spin_unlock_irqrestore(&mac->lock, flags);
 
 	dprintk(KERN_INFO PFX "assoc request timed out!\n");
-	/* FIXME: we need to know the network here. that requires a bit of restructuring */
-	ieee80211softmac_call_events(mac, IEEE80211SOFTMAC_EVENT_ASSOCIATE_TIMEOUT, NULL);
+	ieee80211softmac_call_events(mac, IEEE80211SOFTMAC_EVENT_ASSOCIATE_TIMEOUT, n);
 }
 
 /* Sends out a disassociation request to the desired AP */


