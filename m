From: Junchang Wang <junchangwang@gmail.com>
Subject: [Patch] r8169: use u32 instead of unsigned long
Date: Sat, 29 May 2010 12:01:11 +0800
Message-ID: <20100529040111.GA28225@host-a-55.ustcsz.edu.cn>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: romieu@fr.zoreil.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from [58.211.218.74] ([58.211.218.74]:59200 "EHLO
	host-a-55.ustcsz.edu.cn" rhost-flags-FAIL-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S1750953Ab0E2FES (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 29 May 2010 01:04:18 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

RTL_R32 should return value with 32-bit width. But "unsigned long"
implies u64 on some 64-bit platforms.

Signed-off-by: Junchang Wang <junchangwang@gmail.com>
---
Sorry for coding style flaw in previous email. 

drivers/net/r8169.c |    2 +-
1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/r8169.c b/drivers/net/r8169.c
index 217e709..4234d6a 100644
--- a/drivers/net/r8169.c
+++ b/drivers/net/r8169.c
@@ -88,7 +88,7 @@ static const int multicast_filter_limit = 32;
 #define RTL_W32(reg, val32)	writel ((val32), ioaddr + (reg))
 #define RTL_R8(reg)		readb (ioaddr + (reg))
 #define RTL_R16(reg)		readw (ioaddr + (reg))
-#define RTL_R32(reg)		((unsigned long) readl (ioaddr + (reg)))
+#define RTL_R32(reg)		((u32) readl(ioaddr + (reg)))
 
 enum mac_version {
 	RTL_GIGA_MAC_NONE   = 0x00,
--
