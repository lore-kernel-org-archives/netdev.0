From: Adrian Bunk <bunk@kernel.org>
Subject: [2.6 patch] ibmlana_adapter_names[] must be __devinitdata
Date: Wed, 30 Jan 2008 22:02:10 +0200
Message-ID: <20080130200210.GL29368@does.not.exist>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: jgarzik@pobox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp5.pp.htv.fi ([213.243.153.39]:37553 "EHLO smtp5.pp.htv.fi"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755875AbYA3UBg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 30 Jan 2008 15:01:36 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch fixes the following section mismatch:

<--  snip  -->

...
WARNING: drivers/net/built-in.o(.devinit.text+0x1baa4): Section mismatch in reference from the function ibmlana_init_one() to the variable .init.data:ibmlana_adapter_names
...

<--  snip  -->

Signed-off-by: Adrian Bunk <bunk@kernel.org>

---
50492d4a3ae5358858e6db3572370fb874203074 
diff --git a/drivers/net/ibmlana.c b/drivers/net/ibmlana.c
index 4ccc1cd..95e3464 100644
--- a/drivers/net/ibmlana.c
+++ b/drivers/net/ibmlana.c
@@ -901,7 +901,7 @@ static short ibmlana_adapter_ids[] __initdata = {
 	0x0000
 };
 
-static char *ibmlana_adapter_names[] __initdata = {
+static char *ibmlana_adapter_names[] __devinitdata = {
 	"IBM LAN Adapter/A",
 	NULL
 };

