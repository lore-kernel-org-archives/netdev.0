From: Jiri Benc <jbenc@suse.cz>
Subject: [2/9] ieee80211: fix recursive ipw2200 dependencies
Date: Fri, 3 Jun 2005 18:29:20 +0200
Message-ID: <20050603182920.689a269f@griffin.suse.cz>
References: <20050603182625.64d33be3@griffin.suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Jeff Garzik <jgarzik@pobox.com>, Jirka Bohac <jbohac@suse.cz>
Return-path: <netdev-bounce@oss.sgi.com>
To: NetDev <netdev@oss.sgi.com>
In-Reply-To: <20050603182625.64d33be3@griffin.suse.cz>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

From: Adrian Bunk <bunk@stusta.de>

This results in recursive dependencies:
- IPW2200 depends on NET_RADIO
- IPW2200 selects IEEE80211
- IEEE80211 selects NET_RADIO


This patch fixes the IPW2200 dependencies in a way that they are similar 
to the IPW2100 dependencies.

Signed-off-by: Adrian Bunk <bunk@stusta.de>
Signed-off-by: Jiri Benc <jbenc@suse.cz>

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


-- 
Jiri Benc
SUSE Labs
