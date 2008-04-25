From: Ingo Molnar <mingo@elte.hu>
Subject: Re: [build bug] drivers/built-in.o: In function
	`rt2x00leds_resume': : undefined reference to `led_classdev_resume'
Date: Fri, 25 Apr 2008 09:35:04 +0200
Message-ID: <20080425073504.GA12549@elte.hu>
References: <20080420081302.GA11954@elte.hu> <20080420.020557.231970202.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linville@tuxdriver.com, tomas.winkler@intel.com,
	linux-kernel@vger.kernel.org, kaber@trash.net,
	torvalds@linux-foundation.org, akpm@linux-foundation.org,
	netdev@vger.kernel.org, netfilter-devel@vger.kernel.org,
	mabbas@linux.intel.com, ischram@telenet.be, rjw@sisk.pl,
	ivdoorn@gmail.com
To: David Miller <davem@davemloft.net>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20080420.020557.231970202.davem@davemloft.net>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


* David Miller <davem@davemloft.net> wrote:

> Thanks for your report.
> 
> This is a similar case to the iwlwifi build failure you reported 
> earlier today (where the leds infrastructure knob is modular but the 
> driver using the interfaces is built-in).  Therefore, it likely should 
> use select too.
> 
> This should fix it:
> 
> rt2x00: Select LEDS_CLASS instead of using 'depends'.

hm, it seems there's still some small hole left in its Kconfig 
structure, overnight testing triggered this randconfig combination:

|  drivers/built-in.o: In function `rt2x00leds_resume':
|  : undefined reference to `led_classdev_resume'
|  drivers/built-in.o: In function `rt2x00leds_resume':
|  : undefined reference to `led_classdev_resume'
|
|  http://redhat.com/~mingo/misc/config-Fri_Apr_25_08_50_47_CEST_2008.bad

... no biggie though, the usual distro configs build fine. I've 
reinstated the quick hack below.

btw., for some reason LEDS was a source of various build problems in the 
past too - we fought with it in the x86 tree as well in .25. It seems to 
have problems much more so than other config options that get select-ed. 
Perhaps there's something particularly fragile about LEDS?

	Ingo

-------------->
Subject: rt2x00: turn off temporarily
From: Ingo Molnar <mingo@elte.hu>
Date: Sun Apr 20 10:18:45 CEST 2008

NOT-Signed-off-by: Ingo Molnar <mingo@elte.hu>
---
 drivers/net/wireless/rt2x00/Kconfig |    4 ++++
 1 file changed, 4 insertions(+)

Index: linux/drivers/net/wireless/rt2x00/Kconfig
===================================================================
--- linux.orig/drivers/net/wireless/rt2x00/Kconfig
+++ linux/drivers/net/wireless/rt2x00/Kconfig
@@ -62,6 +62,7 @@ config RT2400PCI_LEDS
 	bool "RT2400 leds support"
 	depends on RT2400PCI
 	select LEDS_CLASS
+	depends on 0
 	select RT2X00_LIB_LEDS
 	---help---
 	  This adds support for led triggers provided my mac80211.
@@ -89,6 +90,7 @@ config RT2500PCI_LEDS
 	bool "RT2500 leds support"
 	depends on RT2500PCI
 	select LEDS_CLASS
+	depends on 0
 	select RT2X00_LIB_LEDS
 	---help---
 	  This adds support for led triggers provided my mac80211.
@@ -118,6 +120,7 @@ config RT61PCI_LEDS
 	bool "RT61 leds support"
 	depends on RT61PCI
 	select LEDS_CLASS
+	depends on 0
 	select RT2X00_LIB_LEDS
 	---help---
 	  This adds support for led triggers provided my mac80211.
@@ -154,6 +157,7 @@ config RT73USB_LEDS
 	bool "RT73 leds support"
 	depends on RT73USB
 	select LEDS_CLASS
+	depends on 0
 	select RT2X00_LIB_LEDS
 	---help---
 	  This adds support for led triggers provided my mac80211.
