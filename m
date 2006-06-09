From: "Randy.Dunlap" <rdunlap@xenotime.net>
Subject: [PATCH] wan/sdla section fixes
Date: Thu, 8 Jun 2006 20:36:16 -0700
Message-ID: <20060608203616.16796ec3.rdunlap@xenotime.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: mike.mclagan@linux.org, khc@pm.waw.pl, akpm <akpm@osdl.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from xenotime.net ([66.160.160.81]:58567 "HELO xenotime.net")
	by vger.kernel.org with SMTP id S965121AbWFIDuU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Jun 2006 23:50:20 -0400
Received: from midway.site ([71.245.102.105]) by xenotime.net for <netdev@vger.kernel.org>; Thu, 8 Jun 2006 20:50:19 -0700
To: netdev <netdev@vger.kernel.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Randy Dunlap <rdunlap@xenotime.net>

Priority: tossup.
netdev->set_config can be called at any time, so these references
to __initdata would be a real problem.
However, problem has not been observed AFAIK.

Fix section mismatch warnings:
WARNING: drivers/net/wan/sdla.o - Section mismatch: reference to .init.data: from .text between 'sdla_set_config' (at offset 0x1b8e) and 'sdla_stats'
WARNING: drivers/net/wan/sdla.o - Section mismatch: reference to .init.data: from .text between 'sdla_set_config' (at offset 0x1e76) and 'sdla_stats'

Signed-off-by: Randy Dunlap <rdunlap@xenotime.net>
---
 drivers/net/wan/sdla.c |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

--- linux-2617-rc6.orig/drivers/net/wan/sdla.c
+++ linux-2617-rc6/drivers/net/wan/sdla.c
@@ -60,9 +60,9 @@
 
 static const char* version = "SDLA driver v0.30, 12 Sep 1996, mike.mclagan@linux.org";
 
-static unsigned int valid_port[] __initdata = { 0x250, 0x270, 0x280, 0x300, 0x350, 0x360, 0x380, 0x390};
+static unsigned int valid_port[] = { 0x250, 0x270, 0x280, 0x300, 0x350, 0x360, 0x380, 0x390};
 
-static unsigned int valid_mem[]  __initdata = {
+static unsigned int valid_mem[] = {
 				    0xA0000, 0xA2000, 0xA4000, 0xA6000, 0xA8000, 0xAA000, 0xAC000, 0xAE000, 
                                     0xB0000, 0xB2000, 0xB4000, 0xB6000, 0xB8000, 0xBA000, 0xBC000, 0xBE000,
                                     0xC0000, 0xC2000, 0xC4000, 0xC6000, 0xC8000, 0xCA000, 0xCC000, 0xCE000,


---
