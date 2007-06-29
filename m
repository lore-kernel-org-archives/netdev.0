From: Francois Romieu <romieu@fr.zoreil.com>
Subject: [PATCH 02/21] r8169: de-obfuscate modulo arithmetic
Date: Fri, 29 Jun 2007 22:17:07 +0200
Message-ID: <20070629201707.GD3240@electric-eye.fr.zoreil.com>
References: <20070629201212.GA3240@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Edward Hsu <edward_hsu@realtek.com.tw>
To: jgarzik@pobox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from electric-eye.fr.zoreil.com ([213.41.134.224]:35049 "EHLO
	fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753147AbXF2UUW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 29 Jun 2007 16:20:22 -0400
Content-Disposition: inline
In-Reply-To: <20070629201212.GA3240@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The former style suggests a modulo arithmetic misuse but
the expression should never be < 0. Even if it does, the
driver will simply loop longer than expected (not that
the remaining parts of the system will necessarily
appreciate it...).

Let's warn the user when something goes wrong and try
to go over it.

Signed-off-by: Francois Romieu <romieu@fr.zoreil.com>
Cc: Edward Hsu <edward_hsu@realtek.com.tw>
---
 drivers/net/r8169.c |    4 +++-
 1 files changed, 3 insertions(+), 1 deletions(-)

diff --git a/drivers/net/r8169.c b/drivers/net/r8169.c
index 4586446..1f7fb54 100644
--- a/drivers/net/r8169.c
+++ b/drivers/net/r8169.c
@@ -2040,10 +2040,12 @@ static u32 rtl8169_rx_fill(struct rtl8169_private *tp, struct net_device *dev,
 {
 	u32 cur;
 
-	for (cur = start; end - cur > 0; cur++) {
+	for (cur = start; end - cur != 0; cur++) {
 		struct sk_buff *skb;
 		unsigned int i = cur % NUM_RX_DESC;
 
+		WARN_ON((s32)(end - cur) < 0);
+
 		if (tp->Rx_skbuff[i])
 			continue;
 
-- 
1.4.4.2

