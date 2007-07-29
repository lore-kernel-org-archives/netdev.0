From: Adrian Bunk <bunk@stusta.de>
Subject: [2.6 patch] make pktgen.c:get_ipsec_sa() static and non-inline
Date: Sun, 29 Jul 2007 16:58:40 +0200
Message-ID: <20070729145840.GY16817@stusta.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Jamal Hadi Salim <hadi@cyberus.ca>,
	Robert Olsson <robert.olsson@its.uu.se>
Return-path: <netdev-owner@vger.kernel.org>
Received: from emailhub.stusta.mhn.de ([141.84.69.5]:47833 "EHLO
	mailhub.stusta.mhn.de" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1764482AbXG2O7D (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 29 Jul 2007 10:59:03 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Non-static inline code usually doesn't makes sense.

In this case making is static and non-inline is the correct solution.

Signed-off-by: Adrian Bunk <bunk@stusta.de>

---
--- linux-2.6.23-rc1-mm1/net/core/pktgen.c.old	2007-07-26 20:12:01.000000000 +0200
+++ linux-2.6.23-rc1-mm1/net/core/pktgen.c	2007-07-26 20:12:13.000000000 +0200
@@ -2156,8 +2156,7 @@
 /* If there was already an IPSEC SA, we keep it as is, else
  * we go look for it ...
 */
-inline
-void get_ipsec_sa(struct pktgen_dev *pkt_dev, int flow)
+static void get_ipsec_sa(struct pktgen_dev *pkt_dev, int flow)
 {
 	struct xfrm_state *x = pkt_dev->flows[flow].x;
 	if (!x) {

