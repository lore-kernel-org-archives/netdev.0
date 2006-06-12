From: Kyle McMartin <kyle@parisc-linux.org>
Subject: [PATCH] Make in-kernel hostap less annoying
Date: Mon, 12 Jun 2006 15:13:02 -0400
Message-ID: <20060612191302.GD32443@skunkworks.cabal.ca>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stout.engsoc.carleton.ca ([134.117.69.22]:62893 "EHLO
	stout.engsoc.carleton.ca") by vger.kernel.org with ESMTP
	id S1750759AbWFLT1S (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 12 Jun 2006 15:27:18 -0400
To: jkmaline@cc.hut.fi
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Most user don't want their kern.log/dmesg filled with
debugging gibberish, and could turn it on if prompted.

( Example:
wifi0: TXEXC - status=0x0004 ([Discon]) tx_control=000c
retry_count=0 tx_rate=0 fc=0x0108 (Data::0 ToDS)
A1=00:0f:66:43:d7:0a A2=00:05:3c:06:63:01 A3=33:33:00:00:00:16 
A4=00:00:00:00:00:00 )


Also make hostap default to managed mode, instead of master mode, which
has bitten a few users expecting it to behave like the orinoco driver
it is replacing.

Signed-off-by: Kyle McMartin <kyle@parisc-linux.org>

---
Two minor things I've been carrying around in my personal tree
for quite some time. (This is only relevant to the in-kernel driver,
I see no reason to change the out-of-tree driver.)

Cheers,
Kyle

diff --git a/drivers/net/wireless/hostap/hostap_config.h b/drivers/net/wireless/hostap/hostap_config.h
index c090a5a..bc51fa9 100644
--- a/drivers/net/wireless/hostap/hostap_config.h
+++ b/drivers/net/wireless/hostap/hostap_config.h
@@ -38,7 +38,7 @@ #endif
  */
 
 /* Do not include debug messages into the driver */
-/* #define PRISM2_NO_DEBUG */
+#define PRISM2_NO_DEBUG
 
 /* Do not include /proc/net/prism2/wlan#/{registers,debug} */
 /* #define PRISM2_NO_PROCFS_DEBUG */
diff --git a/drivers/net/wireless/hostap/hostap_hw.c b/drivers/net/wireless/hostap/hostap_hw.c
index 328e9a1..57438e8 100644
--- a/drivers/net/wireless/hostap/hostap_hw.c
+++ b/drivers/net/wireless/hostap/hostap_hw.c
@@ -70,7 +70,7 @@ static char essid[33] = "test";
 module_param_string(essid, essid, sizeof(essid), 0444);
 MODULE_PARM_DESC(essid, "Host AP's ESSID");
 
-static int iw_mode[MAX_PARM_DEVICES] = { IW_MODE_MASTER, DEF_INTS };
+static int iw_mode[MAX_PARM_DEVICES] = { IW_MODE_INFRA, DEF_INTS };
 module_param_array(iw_mode, int, NULL, 0444);
 MODULE_PARM_DESC(iw_mode, "Initial operation mode");
 
