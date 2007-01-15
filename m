From: Maarten Lankhorst <m.b.lankhorst@gmail.com>
Subject: Re: [PATCH] Remove CONFIG_NET_WIRELESS
Date: Mon, 15 Jan 2007 20:24:21 +0100
Message-ID: <45ABD4E5.6040707@gmail.com>
References: <45A91414.40107@gmail.com>	<1168860268.3344.0.camel@johannes.berg>	<45AB79D1.2070002@gmail.com>	<1168867866.3344.3.camel@johannes.berg> <20070115154008.0dedf451@griffin.suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Johannes Berg <johannes@sipsolutions.net>,
	"John W. Linville" <linville@tuxdriver.com>,
	netdev <netdev@vger.kernel.org>, mb@bu3sch.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailserver.astro.rug.nl ([129.125.6.166]:55172 "EHLO
	mailserver.astro.rug.nl" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751436AbXAOT0K (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Jan 2007 14:26:10 -0500
To: Jiri Benc <jbenc@suse.cz>
In-Reply-To: <20070115154008.0dedf451@griffin.suse.cz>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Jiri Benc schreef:
> On Mon, 15 Jan 2007 13:31:06 +0000, Johannes Berg wrote:
>   
>> On Mon, 2007-01-15 at 13:55 +0100, Maarten Lankhorst wrote:
>>     
>>> Enabling this doesn't cause anything to fail, but my wireless router
>>> doesn't have a pci bus, but instead a native SSB, so CONFIG_NET_WIRELESS
>>> isn't selected. This in turn causes wext-common.o to not be built, so I
>>> get missing symbols and a build breakage. That's why I made
>>> wext-common.o depend on CONFIG_WIRELESS_EXT instead of
>>> CONFIG_NET_WIRELESS. Since nothing else uses CONFIG_NET_WIRELESS I
>>> decided to kill that symbol.
>>>       
>> Ok, that makes sense to me. Let's put this in but with this better
>> description rather than the original one.
>>     
>
> The original mail with patch apparently didn't get to netdev (I haven't
> received it and it's not in netdev archive). Maarten, could you resend
> it please?
>
> Thanks,
>
>  Jiri
>
>   
Sorry, must have missed sending it to netdev, original message follows.

Remove CONFIG_NET_WIRELESS
Nothing uses this, and it breaks the kernel build if a wireless device is used with a unsupported type of bus.
Verified this with a grep.

Signed-off-by: Maarten Lankhorst <m.b.lankhorst@gmail.com>

diff --git a/drivers/net/wireless/Kconfig b/drivers/net/wireless/Kconfig
index 03dbe60..b9620c6 100644
--- a/drivers/net/wireless/Kconfig
+++ b/drivers/net/wireless/Kconfig
@@ -544,11 +544,5 @@ source "drivers/net/wireless/zd1211rw/Kc
 
 source "drivers/net/wireless/d80211/Kconfig"
 
-# yes, this works even when no drivers are selected
-config NET_WIRELESS
-	bool
-	depends on NET_RADIO && (ISA || PCI || PPC_PMAC || PCMCIA)
-	default y
-
 endmenu
 
diff --git a/net/wireless/Makefile b/net/wireless/Makefile
index f285440..44ae23a 100644
--- a/net/wireless/Makefile
+++ b/net/wireless/Makefile
@@ -12,5 +12,5 @@ obj-ny :=
 
 # this needs to be compiled in...
 obj-$(CONFIG_CFG80211_WEXT_COMPAT) += wext-compat.o
-obj-$(CONFIG_CFG80211_WEXT_COMPAT)$(CONFIG_NET_WIRELESS) += wext-common.o
+obj-$(CONFIG_CFG80211_WEXT_COMPAT)$(CONFIG_WIRELESS_EXT) += wext-common.o
 obj-y += $(obj-yy) $(obj-yn) $(obj-ny)

