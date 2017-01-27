From: Edward Cree <ecree@solarflare.com>
Subject: [PATCH net-next 2/4] net: implement netif_cond_dbg macro
Date: Fri, 27 Jan 2017 15:02:26 +0000
Message-ID: <d55a40ab-eb5d-61c9-cae7-7ea865cbb204@solarflare.com>
References: <9baa375c-b3b1-f640-04fb-e234c85a4e93@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>
To: <linux-net-drivers@solarflare.com>, <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nbfkord-smmo03.seg.att.com ([209.65.160.84]:12146 "EHLO
        nbfkord-smmo03.seg.att.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1754921AbdA0PGk (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 27 Jan 2017 10:06:40 -0500
In-Reply-To: <9baa375c-b3b1-f640-04fb-e234c85a4e93@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

For reporting things that may or may not be serious, depending on some
 condition, netif_cond_dbg will check the condition and print the report
 at either dbg (if the condition is true) or the specified level.

Suggested-by: Jon Cooper <jcooper@solarflare.com>
Signed-off-by: Edward Cree <ecree@solarflare.com>
---
 include/linux/netdevice.h | 9 +++++++++
 1 file changed, 9 insertions(+)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 3868c32..b83884c 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -4346,6 +4346,15 @@ do {								\
 })
 #endif
 
+/* if @cond then downgrade to debug, else print at @level */
+#define netif_cond_dbg(priv, type, netdev, cond, level, fmt, args...)     \
+	do {                                                              \
+		if (cond)                                                 \
+			netif_dbg(priv, type, netdev, fmt, ##args);       \
+		else                                                      \
+			netif_ ## level(priv, type, netdev, fmt, ##args); \
+	} while (0)
+
 #if defined(VERBOSE_DEBUG)
 #define netif_vdbg	netif_dbg
 #else
