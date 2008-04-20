From: David Miller <davem@davemloft.net>
Subject: Re: [build bug] iwl-3945-led.c:(.text+0x119e36): undefined
 reference to `__led_classdev_unregister'
Date: Sun, 20 Apr 2008 00:51:49 -0700 (PDT)
Message-ID: <20080420.005149.189096986.davem@davemloft.net>
References: <20080419135602.GA2499@elte.hu>
	<20080420073441.GA31745@elte.hu>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linville@tuxdriver.com, tomas.winkler@intel.com,
	linux-kernel@vger.kernel.org, kaber@trash.net,
	torvalds@linux-foundation.org, akpm@linux-foundation.org,
	netdev@vger.kernel.org, netfilter-devel@vger.kernel.org,
	mabbas@linux.intel.com, ischram@telenet.be, rjw@sisk.pl
To: mingo@elte.hu
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:48991
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751508AbYDTHvs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 20 Apr 2008 03:51:48 -0400
In-Reply-To: <20080420073441.GA31745@elte.hu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ingo Molnar <mingo@elte.hu>
Date: Sun, 20 Apr 2008 09:34:41 +0200

>  drivers/built-in.o: In function `iwl3945_led_unregister_led':
>   iwl-3945-led.c:(.text+0x119e36): undefined reference to `__led_classdev_unregister'
>  drivers/built-in.o: In function `iwl3945_led_register_led':
>   iwl-3945-led.c:(.text+0x119ecd): undefined reference to `led_classdev_register'

Thanks for the report.

This is the classic "API_OPTION=m && API_USER=y" problem.

In this case the best fix is probably to use select in the
iwlwifi Kconfig files.  The following patch should cure it.

iwlwifi: Use 'select' for MAC80211_LEDS and LEDS_CLASS instead of 'depends'

Signed-off-by: David S. Miller <davem@davemloft.net>

diff --git a/drivers/net/wireless/iwlwifi/Kconfig b/drivers/net/wireless/iwlwifi/Kconfig
index f844b73..c4e631d 100644
--- a/drivers/net/wireless/iwlwifi/Kconfig
+++ b/drivers/net/wireless/iwlwifi/Kconfig
@@ -49,7 +49,9 @@ config IWL4965_HT
 
 config IWL4965_LEDS
 	bool "Enable LEDS features in iwl4965 driver"
-	depends on IWL4965 && MAC80211_LEDS && LEDS_CLASS
+	depends on IWL4965
+	select MAC80211_LEDS
+	select LEDS_CLASS
 	select IWLWIFI_LEDS
 	---help---
 	  This option enables LEDS for the iwlwifi drivers
@@ -134,7 +136,9 @@ config IWL3945_SPECTRUM_MEASUREMENT
 
 config IWL3945_LEDS
 	bool "Enable LEDS features in iwl3945 driver"
-	depends on IWL3945 && MAC80211_LEDS && LEDS_CLASS
+	depends on IWL3945
+	select MAC80211_LEDS
+	select LEDS_CLASS
 	---help---
 	  This option enables LEDS for the iwl3945 driver.
 
