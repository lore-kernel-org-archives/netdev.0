From: Jan Niehusmann <jan@gondor.com>
Subject: [PATCH] Re: IPW Question on menuconfig
Date: Mon, 24 Oct 2005 00:36:58 +0200
Message-ID: <20051023223658.GA5367@knautsch.gondor.com>
References: <434B2AE2.1070709@linuxwireless.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	James Ketrenos <jketreno@linux.intel.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1750829AbVJWWhG@vger.kernel.org>
To: Alejandro Bonilla Beeche <abonilla@linuxwireless.org>
Content-Disposition: inline
In-Reply-To: <434B2AE2.1070709@linuxwireless.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Oct 10, 2005 at 09:00:50PM -0600, Alejandro Bonilla Beeche wrote:
> Network devices / Wireless, and the IPW2100 wasn't in the list. I went, 
> then Modularized the IEEE80211 and then IPW2100 was there. I think is 
> kind of estrange that IPW2100 wouldn't show just because it has a 
> dependencie, shouldn't IPW2100 show in the list, and if you select it, 
> then it would also select CONFIG_IEEE80211?

I think you are right, so the config script should be changed like shown
below. (But I'm not really familiar with the config language, so I may
be missing some obvious problems?)

Signed-off-by: Jan Niehusmann <jan@gondor.com>
(in case somebody cares for that for such a small change...)


diff --git a/drivers/net/wireless/Kconfig b/drivers/net/wireless/Kconfig
--- a/drivers/net/wireless/Kconfig
+++ b/drivers/net/wireless/Kconfig
@@ -139,8 +139,9 @@ comment "Wireless 802.11b ISA/PCI cards 
 
 config IPW2100
 	tristate "Intel PRO/Wireless 2100 Network Connection"
-	depends on NET_RADIO && PCI && IEEE80211
+	depends on NET_RADIO && PCI
 	select FW_LOADER
+	select IEEE80211
 	---help---
           A driver for the Intel PRO/Wireless 2100 Network 
 	  Connection 802.11b wireless network adapter.
@@ -192,8 +193,9 @@ config IPW_DEBUG
 
 config IPW2200
 	tristate "Intel PRO/Wireless 2200BG and 2915ABG Network Connection"
-	depends on IEEE80211 && PCI
+	depends on PCI
 	select FW_LOADER
+	select IEEE80211
 	---help---
           A driver for the Intel PRO/Wireless 2200BG and 2915ABG Network
 	  Connection adapters. 
 
