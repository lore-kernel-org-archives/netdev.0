From: David Miller <davem@davemloft.net>
Subject: Re: [build bug] drivers/built-in.o: In function
 `rt2x00leds_resume': : undefined reference to `led_classdev_resume'
Date: Fri, 25 Apr 2008 00:39:47 -0700 (PDT)
Message-ID: <20080425.003947.72853787.davem@davemloft.net>
References: <20080420081302.GA11954@elte.hu>
	<20080420.020557.231970202.davem@davemloft.net>
	<20080425073504.GA12549@elte.hu>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linville@tuxdriver.com, tomas.winkler@intel.com,
	linux-kernel@vger.kernel.org, kaber@trash.net,
	torvalds@linux-foundation.org, akpm@linux-foundation.org,
	netdev@vger.kernel.org, netfilter-devel@vger.kernel.org,
	mabbas@linux.intel.com, ischram@telenet.be, rjw@sisk.pl,
	ivdoorn@gmail.com
To: mingo@elte.hu
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:45826
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1755696AbYDYHjt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 25 Apr 2008 03:39:49 -0400
In-Reply-To: <20080425073504.GA12549@elte.hu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ingo Molnar <mingo@elte.hu>
Date: Fri, 25 Apr 2008 09:35:04 +0200

> hm, it seems there's still some small hole left in its Kconfig 
> structure, overnight testing triggered this randconfig combination:
> 
> |  drivers/built-in.o: In function `rt2x00leds_resume':
> |  : undefined reference to `led_classdev_resume'
> |  drivers/built-in.o: In function `rt2x00leds_resume':
> |  : undefined reference to `led_classdev_resume'
> |
> |  http://redhat.com/~mingo/misc/config-Fri_Apr_25_08_50_47_CEST_2008.bad

This was reported elsewhere as well.

I was sure that the patch below fixed it.

I don't understand how it can still fail, unless the problem is that
selecting "FOO" does not take care to enable any dependencies of
"FOO".

commit 201410ce85d80b7b893cdc72e944a1341dd393f1
Author: David S. Miller <davem@davemloft.net>
Date:   Wed Apr 23 03:34:50 2008 -0700

    rt2x00: Select LEDS_CLASS.
    
    Signed-off-by: David S. Miller <davem@davemloft.net>

diff --git a/drivers/net/wireless/rt2x00/Kconfig b/drivers/net/wireless/rt2x00/Kconfig
index a1e3938..ab1029e 100644
--- a/drivers/net/wireless/rt2x00/Kconfig
+++ b/drivers/net/wireless/rt2x00/Kconfig
@@ -60,7 +60,8 @@ config RT2400PCI_RFKILL
 
 config RT2400PCI_LEDS
 	bool "RT2400 leds support"
-	depends on RT2400PCI && LEDS_CLASS
+	depends on RT2400PCI
+	select LEDS_CLASS
 	select RT2X00_LIB_LEDS
 	---help---
 	  This adds support for led triggers provided my mac80211.
@@ -86,7 +87,8 @@ config RT2500PCI_RFKILL
 
 config RT2500PCI_LEDS
 	bool "RT2500 leds support"
-	depends on RT2500PCI && LEDS_CLASS
+	depends on RT2500PCI
+	select LEDS_CLASS
 	select RT2X00_LIB_LEDS
 	---help---
 	  This adds support for led triggers provided my mac80211.
@@ -114,7 +116,8 @@ config RT61PCI_RFKILL
 
 config RT61PCI_LEDS
 	bool "RT61 leds support"
-	depends on RT61PCI && LEDS_CLASS
+	depends on RT61PCI
+	select LEDS_CLASS
 	select RT2X00_LIB_LEDS
 	---help---
 	  This adds support for led triggers provided my mac80211.
@@ -130,7 +133,8 @@ config RT2500USB
 
 config RT2500USB_LEDS
 	bool "RT2500 leds support"
-	depends on RT2500USB && LEDS_CLASS
+	depends on RT2500USB
+	select LEDS_CLASS
 	select RT2X00_LIB_LEDS
 	---help---
 	  This adds support for led triggers provided my mac80211.
@@ -148,7 +152,8 @@ config RT73USB
 
 config RT73USB_LEDS
 	bool "RT73 leds support"
-	depends on RT73USB && LEDS_CLASS
+	depends on RT73USB
+	select LEDS_CLASS
 	select RT2X00_LIB_LEDS
 	---help---
 	  This adds support for led triggers provided my mac80211.
