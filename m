From: Adrian Bunk <bunk@kernel.org>
Subject: [2.6 patch] drivers/net/sis190.c section fix
Date: Tue, 11 Dec 2007 23:23:56 +0100
Message-ID: <20071211222356.GA14204@stusta.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: romieu@fr.zoreil.com, jgarzik@pobox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from emailhub.stusta.mhn.de ([141.84.69.5]:38553 "EHLO
	mailhub.stusta.mhn.de" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1754869AbXLKWX4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 Dec 2007 17:23:56 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch fixes the following section mismatch with CONFIG_HOTPLUG=n:

<--  snip  -->

...
WARNING: vmlinux.o(.init.text.20+0x4cb25): Section mismatch: reference to .exit.text:sis190_mii_remove (between 'sis190_init_one' and 'read_eeprom')
...

<--  snip  -->

Signed-off-by: Adrian Bunk <bunk@kernel.org>

---
29fae057ba15a552a7cad1e731d3238d567032ba 
diff --git a/drivers/net/sis190.c b/drivers/net/sis190.c
index 7200883..49f767b 100644
--- a/drivers/net/sis190.c
+++ b/drivers/net/sis190.c
@@ -1381,7 +1381,7 @@ out:
 	return rc;
 }
 
-static void __devexit sis190_mii_remove(struct net_device *dev)
+static void sis190_mii_remove(struct net_device *dev)
 {
 	struct sis190_private *tp = netdev_priv(dev);
 

