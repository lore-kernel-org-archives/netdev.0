From: Adrian Bunk <bunk@stusta.de>
Subject: [-mm patch] fix recursive IPW2200 dependencies
Date: Thu, 2 Jun 2005 22:07:02 +0200
Message-ID: <20050602200701.GG4992@stusta.de>
References: <20050601022824.33c8206e.akpm@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, hostap@shmoo.com, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Andrew Morton <akpm@osdl.org>, jkmaline@cc.hut.fi, jgarzik@pobox.com
Content-Disposition: inline
In-Reply-To: <20050601022824.33c8206e.akpm@osdl.org>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, Jun 01, 2005 at 02:28:24AM -0700, Andrew Morton wrote:
>...
> Changes since 2.6.12-rc5-mm1:
>...
> +git-netdev-we18-ieee80211-wifi.patch
> 
>  Various things added and merged in netdev land.
>...

This results in recursive dependencies:
- IPW2200 depends on NET_RADIO
- IPW2200 selects IEEE80211
- IEEE80211 selects NET_RADIO


This patch fixes the IPW2200 dependencies in a way that they are similar 
to the IPW2100 dependencies.

Signed-off-by: Adrian Bunk <bunk@stusta.de>

--- linux-2.6.12-rc5-mm2-full/drivers/net/wireless/Kconfig.old	2005-06-02 22:04:02.000000000 +0200
+++ linux-2.6.12-rc5-mm2-full/drivers/net/wireless/Kconfig	2005-06-02 22:04:40.000000000 +0200
@@ -192,9 +192,8 @@
 
 config IPW2200
 	tristate "Intel PRO/Wireless 2200BG and 2915ABG Network Connection"
-	depends on NET_RADIO && PCI
+	depends on IEEE80211 && PCI
 	select FW_LOADER
-	select IEEE80211
 	---help---
           A driver for the Intel PRO/Wireless 2200BG and 2915ABG Network
 	  Connection adapters. 
