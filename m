From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH 11/16] mii: Add mii_advertise_flowctrl()
Date: Wed, 29 Apr 2009 19:19:03 +0100
Message-ID: <1241029143.3246.60.camel@achroite>
References: <1241028086.3246.30.camel@achroite>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smarthost02.mail.zen.net.uk ([212.23.3.141]:59544 "EHLO
	smarthost02.mail.zen.net.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757846AbZD2STJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Apr 2009 14:19:09 -0400
In-Reply-To: <1241028086.3246.30.camel@achroite>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This converts flow control capabilites to an advertising mask and can
be useful in combination with mii_resolve_flowctrl_fdx().

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
This is intended to be used to implement ETHTOOL_SPAUSEPARAM when
autoneg is set, but I'm not sure how that command is supposed to
interact with pause autonegotiation flags set through ETHTOOL_SSET.

Ben.

 include/linux/mii.h |   16 ++++++++++++++++
 1 files changed, 16 insertions(+), 0 deletions(-)

diff --git a/include/linux/mii.h b/include/linux/mii.h
index 14ecb2e..359fba8 100644
--- a/include/linux/mii.h
+++ b/include/linux/mii.h
@@ -240,6 +240,22 @@ static inline unsigned int mii_duplex (unsigned int duplex_lock,
 }
 
 /**
+ * mii_advertise_flowctrl - get flow control advertisement flags
+ * @cap: Flow control capabilities (FLOW_CTRL_RX, FLOW_CTRL_TX or both)
+ */
+static inline u16 mii_advertise_flowctrl(int cap)
+{
+	u16 adv = 0;
+
+	if (cap & FLOW_CTRL_RX)
+		adv = ADVERTISE_PAUSE_CAP | ADVERTISE_PAUSE_ASYM;
+	if (cap & FLOW_CTRL_TX)
+		adv ^= ADVERTISE_PAUSE_ASYM;
+
+	return adv;
+}
+
+/**
  * mii_resolve_flowctrl_fdx
  * @lcladv: value of MII ADVERTISE register
  * @rmtadv: value of MII LPA register

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

