From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: s390 allmodconfig
Date: Fri, 02 Mar 2007 11:38:24 +0100
Message-ID: <1172831904.3482.13.camel@johannes.berg>
References: <20070302001811.b103e2b2.akpm@linux-foundation.org>
	 <20070302002512.bd9bbb80.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Marcel Holtmann <marcel@holtmann.org>,
	"John W. Linville" <linville@tuxdriver.com>,
	Michael Buesch <mb@bu3sch.de>,
	Richard Purdie <rpurdie@rpsys.net>, netdev@vger.kernel.org
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from crystal.sipsolutions.net ([195.210.38.204]:52413 "EHLO
	sipsolutions.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933318AbXCBKj0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 2 Mar 2007 05:39:26 -0500
In-Reply-To: <20070302002512.bd9bbb80.akpm@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 2007-03-02 at 00:25 -0800, Andrew Morton wrote:

> Probably related to the Kconfig problems.

Yeah, it is. s390 is funny, it doesn't include drivers/Kconfig, I don't
think anybody of us would have suspected that.

There doesn't seem to be a reason why it shouldn't have drivers/leds
though. drivers/ssb I don't know about, does s390 have pci or pcmcia?
And the bluetooth stuff is also plain weird, I suppose s390 really
should include drivers/hid/Kconfig :)

Same with drivers/char that includes hw_random.

Is there any reason it isn't including drivers/Kconfig? 


I can offer below patch to fix the LED trigger problem, it's probably
cleaner to depend on LEDS_TRIGGERS rather than selecting it and
NEW_LEDS.

johannes

--- wireless-dev.orig/net/mac80211/Kconfig	2007-03-02 11:18:45.464333268 +0100
+++ wireless-dev/net/mac80211/Kconfig	2007-03-02 11:33:24.534333268 +0100
@@ -13,9 +13,7 @@ config MAC80211
 
 config MAC80211_LEDS
 	bool "Enable LED triggers"
-	depends on MAC80211
-	select NEW_LEDS
-	select LEDS_TRIGGERS
+	depends on MAC80211 && LEDS_TRIGGERS
 	---help---
 	This option enables a few LED triggers for different
 	packet receive/transmit events.


