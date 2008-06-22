From: Ben Dooks <ben-linux@fluff.org>
Subject: [patch v2 02/11] DM9000: Fixup blackfin after removing 2 resource usage
Date: Sun, 22 Jun 2008 21:16:47 +0100
Message-ID: <20080622201904.747948172@fluff.org.uk>
References: <20080622201645.041001353@fluff.org.uk>
Cc: jeff@garzik.org, Bryan Wu <cooloney@kernel.org>,
	Ben Dooks <ben-linux@fluff.org>,
	Laurent Pinchart <laurentp@cse-semaphore.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from aeryn.fluff.org.uk ([87.194.8.8]:56678 "EHLO
	kira.home.fluff.org" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1754808AbYFVUTI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 22 Jun 2008 16:19:08 -0400
Content-Disposition: inline; filename=thirdparty/dm9000-fixup-blackfin.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Laurent Pinchart <laurentp@cse-semaphore.com>

The dm9000 driver accepts either 2 or 3 resources to describe the platform
devices. The 2 resources case abuses the ioresource mechanism by passing
ioremap()ed memory through the platform device resources. This patch removes
converts boards that were using it to the 3 resources scheme.

CC: Bryan Wu <cooloney@kernel.org>
Signed-off-by: Ben Dooks <ben-linux@fluff.org>
Signed-off-by: Laurent Pinchart <laurentp@cse-semaphore.com>

diff --git a/arch/blackfin/mach-bf527/boards/ezkit.c b/arch/blackfin/mach-bf527/boards/ezkit.c
index 5958eec..689b69c 100644
--- a/arch/blackfin/mach-bf527/boards/ezkit.c
+++ b/arch/blackfin/mach-bf527/boards/ezkit.c
@@ -323,10 +323,15 @@ static struct platform_device smc91x_device = {
 static struct resource dm9000_resources[] = {
 	[0] = {
 		.start	= 0x203FB800,
-		.end	= 0x203FB800 + 8,
+		.end	= 0x203FB800 + 1,
 		.flags	= IORESOURCE_MEM,
 	},
 	[1] = {
+		.start	= 0x203FB800 + 4,
+		.end	= 0x203FB800 + 5,
+		.flags	= IORESOURCE_MEM,
+	},
+	[2] = {
 		.start	= IRQ_PF9,
 		.end	= IRQ_PF9,
 		.flags	= (IORESOURCE_IRQ | IORESOURCE_IRQ_HIGHEDGE),
diff --git a/arch/blackfin/mach-bf533/boards/H8606.c b/arch/blackfin/mach-bf533/boards/H8606.c
index 7cc4864..4103a97 100644
--- a/arch/blackfin/mach-bf533/boards/H8606.c
+++ b/arch/blackfin/mach-bf533/boards/H8606.c
@@ -65,10 +65,15 @@ static struct platform_device rtc_device = {
 static struct resource dm9000_resources[] = {
 	[0] = {
 		.start	= 0x20300000,
-		.end	= 0x20300000 + 8,
+		.end	= 0x20300000 + 1,
 		.flags	= IORESOURCE_MEM,
 	},
 	[1] = {
+		.start	= 0x20300000 + 4,
+		.end	= 0x20300000 + 5,
+		.flags	= IORESOURCE_MEM,
+	},
+	[2] = {
 		.start	= IRQ_PF10,
 		.end	= IRQ_PF10,
 		.flags	= (IORESOURCE_IRQ | IORESOURCE_IRQ_HIGHEDGE),
diff --git a/arch/blackfin/mach-bf537/boards/generic_board.c b/arch/blackfin/mach-bf537/boards/generic_board.c
index 7d25082..01b63e2 100644
--- a/arch/blackfin/mach-bf537/boards/generic_board.c
+++ b/arch/blackfin/mach-bf537/boards/generic_board.c
@@ -166,10 +166,15 @@ static struct platform_device smc91x_device = {
 static struct resource dm9000_resources[] = {
 	[0] = {
 		.start	= 0x203FB800,
-		.end	= 0x203FB800 + 8,
+		.end	= 0x203FB800 + 1,
 		.flags	= IORESOURCE_MEM,
 	},
 	[1] = {
+		.start	= 0x203FB800 + 4,
+		.end	= 0x203FB800 + 5,
+		.flags	= IORESOURCE_MEM,
+	},
+	[2] = {
 		.start	= IRQ_PF9,
 		.end	= IRQ_PF9,
 		.flags	= (IORESOURCE_IRQ | IORESOURCE_IRQ_HIGHEDGE),

-- 
Ben (ben@fluff.org, http://www.fluff.org/)

  'a smiley only costs 4 bytes'
