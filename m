From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH 10/16] mii: Simplify mii_resolve_flowctrl_fdx()
Date: Wed, 29 Apr 2009 19:15:05 +0100
Message-ID: <1241028905.3246.55.camel@achroite>
References: <1241028086.3246.30.camel@achroite>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com,
	Steve Glendinning <steve.glendinning@smsc.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smarthost01.mail.zen.net.uk ([212.23.3.140]:39295 "EHLO
	smarthost01.mail.zen.net.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752233AbZD2SPH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Apr 2009 14:15:07 -0400
In-Reply-To: <1241028086.3246.30.camel@achroite>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a shorter and more comprehensible formulation of the
conditions for each flow control mode.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 include/linux/mii.h |   18 ++++++------------
 1 files changed, 6 insertions(+), 12 deletions(-)

diff --git a/include/linux/mii.h b/include/linux/mii.h
index ad74858..14ecb2e 100644
--- a/include/linux/mii.h
+++ b/include/linux/mii.h
@@ -250,18 +250,12 @@ static inline u8 mii_resolve_flowctrl_fdx(u16 lcladv, u16 rmtadv)
 {
 	u8 cap = 0;
 
-	if (lcladv & ADVERTISE_PAUSE_CAP) {
-		if (lcladv & ADVERTISE_PAUSE_ASYM) {
-			if (rmtadv & LPA_PAUSE_CAP)
-				cap = FLOW_CTRL_TX | FLOW_CTRL_RX;
-			else if (rmtadv & LPA_PAUSE_ASYM)
-				cap = FLOW_CTRL_RX;
-		} else {
-			if (rmtadv & LPA_PAUSE_CAP)
-				cap = FLOW_CTRL_TX | FLOW_CTRL_RX;
-		}
-	} else if (lcladv & ADVERTISE_PAUSE_ASYM) {
-		if ((rmtadv & LPA_PAUSE_CAP) && (rmtadv & LPA_PAUSE_ASYM))
+	if (lcladv & rmtadv & ADVERTISE_PAUSE_CAP) {
+		cap = FLOW_CTRL_TX | FLOW_CTRL_RX;
+	} else if (lcladv & rmtadv & ADVERTISE_PAUSE_ASYM) {
+		if (lcladv & ADVERTISE_PAUSE_CAP)
+			cap = FLOW_CTRL_RX;
+		else if (rmtadv & ADVERTISE_PAUSE_CAP)
 			cap = FLOW_CTRL_TX;
 	}
 

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

