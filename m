From: Adrian Bunk <bunk@stusta.de>
Subject: [2.6 patch] PCMCIA_SPECTRUM must select FW_LOADER
Date: Fri, 24 Mar 2006 17:56:19 +0100
Message-ID: <20060324165619.GG22727@stusta.de>
References: <44241FF9.9070904@ums.usu.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: LKML <linux-kernel@vger.kernel.org>, netdev@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1751140AbWCXQ4b@vger.kernel.org>
To: "Alexander E. Patrakov" <patrakov@ums.usu.ru>,
	linville@tuxdriver.com
Content-Disposition: inline
In-Reply-To: <44241FF9.9070904@ums.usu.ru>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Mar 24, 2006 at 09:36:09PM +0500, Alexander E. Patrakov wrote:
> In linux-2.6.16, it is possible to compile spectrum_cs.ko without enabling 
> firmware loader. Result:
> 
> WARNING: /lib/modules/2.6.16/kernel/drivers/net/wireless/spectrum_cs.ko 
> needs unknown symbol request_firmware

Thanks for your report, a fix is below.

> Alexander E. Patrakov

cu
Adrian


<--  snip  -->


PCMCIA_SPECTRUM must select FW_LOADER.

Reported by "Alexander E. Patrakov" <patrakov@ums.usu.ru>.

Signed-off-by: Adrian Bunk <bunk@stusta.de>

--- linux-2.6.16-mm1-full/drivers/net/wireless/Kconfig.old	2006-03-24 17:45:05.000000000 +0100
+++ linux-2.6.16-mm1-full/drivers/net/wireless/Kconfig	2006-03-24 17:45:38.000000000 +0100
@@ -397,6 +397,7 @@
 config PCMCIA_SPECTRUM
 	tristate "Symbol Spectrum24 Trilogy PCMCIA card support"
 	depends on NET_RADIO && PCMCIA && HERMES
+	select FW_LOADER
 	---help---
 
 	  This is a driver for 802.11b cards using RAM-loadable Symbol
