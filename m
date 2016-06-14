From: Alexander Aring <aar@pengutronix.de>
Subject: [PATCHv3 net-next 04/12] ndisc: add __ndisc_opt_addr_space function
Date: Tue, 14 Jun 2016 13:52:31 +0200
Message-ID: <20160614115239.17788-5-aar@pengutronix.de>
References: <20160614115239.17788-1-aar@pengutronix.de>
Cc: kernel@pengutronix.de, marcel@holtmann.org,
	jukka.rissanen@linux.intel.com, hannes@stressinduktion.org,
	stefan@osg.samsung.com, mcr@sandelman.ca, werner@almesberger.net,
	linux-bluetooth@vger.kernel.org, netdev@vger.kernel.org,
	Alexander Aring <aar@pengutronix.de>,
	"David S . Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>
To: linux-wpan@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.4.pengutronix.de ([92.198.50.35]:50973 "EHLO
	metis.ext.4.pengutronix.de" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751967AbcFNLxR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Jun 2016 07:53:17 -0400
In-Reply-To: <20160614115239.17788-1-aar@pengutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds __ndisc_opt_addr_space as low-level function for
ndisc_opt_addr_space which doesn't depend on net_device parameter.

Cc: David S. Miller <davem@davemloft.net>
Cc: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
Cc: James Morris <jmorris@namei.org>
Cc: Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>
Cc: Patrick McHardy <kaber@trash.net>
Signed-off-by: Alexander Aring <aar@pengutronix.de>
---
 include/net/ndisc.h | 9 +++++++--
 1 file changed, 7 insertions(+), 2 deletions(-)

diff --git a/include/net/ndisc.h b/include/net/ndisc.h
index 2d8edaa..4cee826 100644
--- a/include/net/ndisc.h
+++ b/include/net/ndisc.h
@@ -127,10 +127,15 @@ static inline int ndisc_addr_option_pad(unsigned short type)
 	}
 }
 
+static inline int __ndisc_opt_addr_space(unsigned char addr_len, int pad)
+{
+	return NDISC_OPT_SPACE(addr_len + pad);
+}
+
 static inline int ndisc_opt_addr_space(struct net_device *dev)
 {
-	return NDISC_OPT_SPACE(dev->addr_len +
-			       ndisc_addr_option_pad(dev->type));
+	return __ndisc_opt_addr_space(dev->addr_len,
+				      ndisc_addr_option_pad(dev->type));
 }
 
 static inline u8 *ndisc_opt_addr_data(struct nd_opt_hdr *p,
-- 
2.8.3
