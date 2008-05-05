From: Adrian Bunk <bunk@kernel.org>
Subject: [2.6 patch] make IWLWIFI a tristate
Date: Mon, 5 May 2008 21:25:16 +0300
Message-ID: <20080505182516.GM17139@cs181133002.pp.htv.fi>
References: <87zlrgl09s.fsf@sparse.dyndns.org> <1209435597.2624.35.camel@debian.sh.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: Jason Riedy <jason@acm.org>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Zhu Yi <yi.zhu@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp4.pp.htv.fi ([213.243.153.38]:54938 "EHLO smtp4.pp.htv.fi"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1760445AbYEES0Y (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 5 May 2008 14:26:24 -0400
Content-Disposition: inline
In-Reply-To: <1209435597.2624.35.camel@debian.sh.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Apr 29, 2008 at 10:19:57AM +0800, Zhu Yi wrote:
> On Sat, 2008-04-26 at 15:27 -0700, Jason Riedy wrote:
> > If IWL3945 ever depends on IWLCORE, the silent, user-invisible
> > IWLWIFI option can go away.
> > 
> > Signed-off-by: Jason Riedy <jason@acm.org>
> > ---
> >    The breakage made it to Linus's tree but isn't in the wireless forest
> >    (as far as I can see).  Commit 49186b4a083655 is a "part 2" without
> >    a "part 1", so perhaps that "part 1" avoided the problem?
> > 
> >  drivers/net/wireless/Makefile        |    2 +-
> >  drivers/net/wireless/iwlwifi/Kconfig |    6 ++++++
> >  2 files changed, 7 insertions(+), 1 deletions(-)
> > 
> > diff --git a/drivers/net/wireless/Makefile b/drivers/net/wireless/Makefile
> > index c2642bc..2c343aa 100644
> > --- a/drivers/net/wireless/Makefile
> > +++ b/drivers/net/wireless/Makefile
> > @@ -56,7 +56,7 @@ obj-$(CONFIG_RTL8187)	+= rtl8187.o
> >  
> >  obj-$(CONFIG_ADM8211)	+= adm8211.o
> >  
> > -obj-$(CONFIG_IWLCORE)	+= iwlwifi/
> > +obj-$(CONFIG_IWLWIFI)	+= iwlwifi/
> >  obj-$(CONFIG_RT2X00)	+= rt2x00/
> >  
> >  obj-$(CONFIG_P54_COMMON)	+= p54/
> > diff --git a/drivers/net/wireless/iwlwifi/Kconfig b/drivers/net/wireless/iwlwifi/Kconfig
> > index c4e631d..9a25f55 100644
> > --- a/drivers/net/wireless/iwlwifi/Kconfig
> > +++ b/drivers/net/wireless/iwlwifi/Kconfig
> > @@ -1,6 +1,11 @@
> > +config IWLWIFI
> > +	bool
> > +	default n
> > +
> >  config IWLCORE
> >  	tristate "Intel Wireless Wifi Core"
> >  	depends on PCI && MAC80211 && WLAN_80211 && EXPERIMENTAL
> > +	select IWLWIFI
> >  
> >  config IWLWIFI_LEDS
> >  	bool
> > @@ -106,6 +111,7 @@ config IWL3945
> >  	tristate "Intel PRO/Wireless 3945ABG/BG Network Connection"
> >  	depends on PCI && MAC80211 && WLAN_80211 && EXPERIMENTAL
> >  	select FW_LOADER
> > +	select IWLWIFI
> >  	---help---
> >  	  Select to build the driver supporting the:
> 
> Do we have a way to make "select IWLWIFI" generate CONFIG_IWLWIFI with
> the same state as CONFIG_IWLCORE (or CONFIG_IWL3945)?
>...

Fix below.

> Thanks,
> -yi

cu
Adrian


<--  snip  -->


IWLWIFI should be a tristate so that if IWLCORE and/or IWL3945 are m
and none of them is y kbuild doesn't create an empty 
drivers/net/wireless/built-in.o

This patch also removes the pointless "default n".

Signed-off-by: Adrian Bunk <bunk@kernel.org>

---
f9737a109a127754ae7cc35e94d44fb426e0dea1 diff --git a/drivers/net/wireless/iwlwifi/Kconfig b/drivers/net/wireless/iwlwifi/Kconfig
index d5b7a76..62fb89d 100644
--- a/drivers/net/wireless/iwlwifi/Kconfig
+++ b/drivers/net/wireless/iwlwifi/Kconfig
@@ -1,6 +1,5 @@
 config IWLWIFI
-	bool
-	default n
+	tristate
 
 config IWLCORE
 	tristate "Intel Wireless Wifi Core"

