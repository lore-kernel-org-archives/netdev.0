From: "Winkler, Tomas" <tomas.winkler@intel.com>
Subject: RE: [build bug] iwl-3945-led.c:(.text+0x119e36): undefined reference to `__led_classdev_unregister'
Date: Mon, 21 Apr 2008 20:03:06 +0300
Message-ID: <C07C4589BE74A34981C3C3525EE1F80103BAF8B5@hasmsx412.ger.corp.intel.com>
References: <20080419135602.GA2499@elte.hu><20080420073441.GA31745@elte.hu> <20080420.005149.189096986.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: <linville@tuxdriver.com>, <linux-kernel@vger.kernel.org>,
	<kaber@trash.net>, <torvalds@linux-foundation.org>,
	<akpm@linux-foundation.org>, <netdev@vger.kernel.org>,
	<netfilter-devel@vger.kernel.org>, <mabbas@linux.intel.com>,
	<ischram@telenet.be>, <rjw@sisk.pl>
To: "David Miller" <davem@davemloft.net>, <mingo@elte.hu>,
	"Chatre, Reinette" <reinette.chatre@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:33196 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753120AbYDURDO convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Apr 2008 13:03:14 -0400
Content-class: urn:content-classes:message
In-Reply-To: <20080420.005149.189096986.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



>-----Original Message-----
>From: David Miller [mailto:davem@davemloft.net]
>Sent: Sunday, April 20, 2008 10:52 AM
>To: mingo@elte.hu
>Cc: linville@tuxdriver.com; Winkler, Tomas;
linux-kernel@vger.kernel.org;
>kaber@trash.net; torvalds@linux-foundation.org;
akpm@linux-foundation.org;
>netdev@vger.kernel.org; netfilter-devel@vger.kernel.org;
>mabbas@linux.intel.com; ischram@telenet.be; rjw@sisk.pl
>Subject: Re: [build bug] iwl-3945-led.c:(.text+0x119e36): undefined
>reference to `__led_classdev_unregister'
>
>From: Ingo Molnar <mingo@elte.hu>
>Date: Sun, 20 Apr 2008 09:34:41 +0200
>
>>  drivers/built-in.o: In function `iwl3945_led_unregister_led':
>>   iwl-3945-led.c:(.text+0x119e36): undefined reference to
>`__led_classdev_unregister'
>>  drivers/built-in.o: In function `iwl3945_led_register_led':
>>   iwl-3945-led.c:(.text+0x119ecd): undefined reference to
>`led_classdev_register'
>
>Thanks for the report.
>
>This is the classic "API_OPTION=m && API_USER=y" problem.
>
>In this case the best fix is probably to use select in the
>iwlwifi Kconfig files.  The following patch should cure it.
>
>iwlwifi: Use 'select' for MAC80211_LEDS and LEDS_CLASS instead of
'depends'
>
>Signed-off-by: David S. Miller <davem@davemloft.net>
>
>diff --git a/drivers/net/wireless/iwlwifi/Kconfig
>b/drivers/net/wireless/iwlwifi/Kconfig
>index f844b73..c4e631d 100644
>--- a/drivers/net/wireless/iwlwifi/Kconfig
>+++ b/drivers/net/wireless/iwlwifi/Kconfig
>@@ -49,7 +49,9 @@ config IWL4965_HT
>
> config IWL4965_LEDS
> 	bool "Enable LEDS features in iwl4965 driver"
>-	depends on IWL4965 && MAC80211_LEDS && LEDS_CLASS
>+	depends on IWL4965
>+	select MAC80211_LEDS
>+	select LEDS_CLASS
> 	select IWLWIFI_LEDS
> 	---help---
> 	  This option enables LEDS for the iwlwifi drivers
>@@ -134,7 +136,9 @@ config IWL3945_SPECTRUM_MEASUREMENT
>
> config IWL3945_LEDS
> 	bool "Enable LEDS features in iwl3945 driver"
>-	depends on IWL3945 && MAC80211_LEDS && LEDS_CLASS
>+	depends on IWL3945
>+	select MAC80211_LEDS
>+	select LEDS_CLASS
> 	---help---
> 	  This option enables LEDS for the iwl3945 driver.
>

ACK
---------------------------------------------------------------------
Intel Israel (74) Limited

This e-mail and any attachments may contain confidential material for
the sole use of the intended recipient(s). Any review or distribution
by others is strictly prohibited. If you are not the intended
recipient, please contact the sender and delete all copies.

