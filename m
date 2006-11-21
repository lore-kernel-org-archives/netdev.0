From: Michael Buesch <mb@bu3sch.de>
Subject: Re: RFC/T: Trial fix for the bcm43xx - wpa_supplicant - NetworkManager deadlock
Date: Tue, 21 Nov 2006 09:59:17 +0100
Message-ID: <200611210959.17644.mb@bu3sch.de>
References: <4561DBE0.2060908@lwfinger.net> <200611210017.47695.mb@bu3sch.de> <1164098989.2769.9.camel@ux156>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-15"
Content-Transfer-Encoding: 7bit
Cc: Larry Finger <Larry.Finger@lwfinger.net>,
	Dan Williams <dcbw@redhat.com>, Ray Lee <ray-lk@madrabbit.org>,
	bcm43xx-dev@lists.berlios.de, Joseph Fannin <jhf@columbus.rr.com>,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from static-ip-62-75-166-246.inaddr.intergenia.de ([62.75.166.246]:60819
	"EHLO bu3sch.de") by vger.kernel.org with ESMTP id S1030745AbWKUJBP
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 21 Nov 2006 04:01:15 -0500
To: Johannes Berg <johannes@sipsolutions.net>
In-Reply-To: <1164098989.2769.9.camel@ux156>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tuesday 21 November 2006 09:49, Johannes Berg wrote:
> On Tue, 2006-11-21 at 00:17 +0100, Michael Buesch wrote:
> 
> > So, how to fix this?
> > Actually, do we even _have_ to disable TX when scanning? I'd say no.
> > Opinions?
> 
> For active scanning we can't disable TX. And for passive scanning the
> firmware will block unwanted frames from going out on the wrong
> channel :)


Ok, so people, please do test this patch.
I did not test it myself, but I am pretty sure it will fix
a lot of mysterious and unobvious bugs people are seeing.


Signed-off-by: Michael Buesch <mb@bu3sch.de>

Index: wireless-2.6/net/ieee80211/softmac/ieee80211softmac_scan.c
===================================================================
--- wireless-2.6.orig/net/ieee80211/softmac/ieee80211softmac_scan.c	2006-09-27 19:34:20.000000000 +0200
+++ wireless-2.6/net/ieee80211/softmac/ieee80211softmac_scan.c	2006-11-21 09:57:14.000000000 +0100
@@ -47,7 +47,6 @@ ieee80211softmac_start_scan(struct ieee8
 	sm->scanning = 1;
 	spin_unlock_irqrestore(&sm->lock, flags);
 
-	netif_tx_disable(sm->ieee->dev);
 	ret = sm->start_scan(sm->dev);
 	if (ret) {
 		spin_lock_irqsave(&sm->lock, flags);
@@ -248,7 +247,6 @@ void ieee80211softmac_scan_finished(stru
 		if (net)
 			sm->set_channel(sm->dev, net->channel);
 	}
-	netif_wake_queue(sm->ieee->dev);
 	ieee80211softmac_call_events(sm, IEEE80211SOFTMAC_EVENT_SCAN_FINISHED, NULL);
 }
 EXPORT_SYMBOL_GPL(ieee80211softmac_scan_finished);


-- 
Greetings Michael.
