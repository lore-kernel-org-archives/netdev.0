From: yalin wang <yalin.wang2010@gmail.com>
Subject: [PATCH] net/fddi:change HWM_REVERSE() macro
Date: Tue, 11 Aug 2015 00:14:06 +0800
Message-ID: <6AE77A24-5AC5-47E4-8B9F-9BCDE0C6A8F9@gmail.com>
Mime-Version: 1.0 (Mac OS X Mail 8.2 \(2098\))
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 8BIT
To: netdev@vger.kernel.org, open list <linux-kernel@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f46.google.com ([209.85.220.46]:34523 "EHLO
	mail-pa0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753366AbbHJQOr convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Aug 2015 12:14:47 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

change HWM_REVERSE() macro to generic le32_to_cpu()

Signed-off-by: yalin wang <yalin.wang2010@gmail.com>
---
 drivers/net/fddi/skfp/h/hwmtm.h | 11 ++---------
 1 file changed, 2 insertions(+), 9 deletions(-)

diff --git a/drivers/net/fddi/skfp/h/hwmtm.h b/drivers/net/fddi/skfp/h/hwmtm.h
index 5924d42..72701ef 100644
--- a/drivers/net/fddi/skfp/h/hwmtm.h
+++ b/drivers/net/fddi/skfp/h/hwmtm.h
@@ -14,7 +14,7 @@
 
 #ifndef	_HWM_
 #define	_HWM_
-
+#include <linux/byteorder/generic.h>
 #include "mbuf.h"
 
 /*
@@ -74,14 +74,7 @@
 #define NULL 		0
 #endif
 
-#ifdef	LITTLE_ENDIAN
-#define HWM_REVERSE(x)	(x)
-#else
-#define	HWM_REVERSE(x)		((((x)<<24L)&0xff000000L)	+	\
-				 (((x)<< 8L)&0x00ff0000L)	+	\
-				 (((x)>> 8L)&0x0000ff00L)	+	\
-				 (((x)>>24L)&0x000000ffL))
-#endif
+#define HWM_REVERSE(x) le32_to_cpu(x)
 
 #define C_INDIC		(1L<<25)
 #define A_INDIC		(1L<<26)
-- 
1.9.1
