From: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Subject: [net-next 2/3] stmmac: fix timer setup when use dual mac Kconfig
Date: Tue, 27 Jul 2010 12:09:46 +0200
Message-ID: <1280225387-26240-2-git-send-email-peppe.cavallaro@st.com>
References: <1280225387-26240-1-git-send-email-peppe.cavallaro@st.com>
Cc: Giuseppe Cavallaro <peppe.cavallaro@st.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog118.obsmtp.com ([207.126.144.145]:36392 "EHLO
	eu1sys200aog118.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753703Ab0G0KKB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Jul 2010 06:10:01 -0400
Received: from zeta.dmz-eu.st.com (ns2.st.com [164.129.230.9])
	by beta.dmz-eu.st.com (STMicroelectronics) with ESMTP id 6D6C7122
	for <netdev@vger.kernel.org>; Tue, 27 Jul 2010 10:09:59 +0000 (GMT)
Received: from mail3.ctn.st.com (mail3.ctn.st.com [164.130.116.150])
	by zeta.dmz-eu.st.com (STMicroelectronics) with ESMTP id 3394E2651
	for <netdev@vger.kernel.org>; Tue, 27 Jul 2010 10:09:59 +0000 (GMT)
In-Reply-To: <1280225387-26240-1-git-send-email-peppe.cavallaro@st.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The driver erroneously sets the tmrate to zero when the
TMU initialisation fails. This actually generates problems
while using the dual GMAC configuration.

With this patch, enabling both the dual gmac and the timer
optimisation, the first interface opened will use the tmu
channel 2, the second one won't be able to use the timer but
will continue to work without mitigating the interrupts by
using the external timer (i.e. TMU channel 2).

Signed-off-by: Giuseppe Cavallaro <peppe.cavallaro@st.com>
---
 drivers/net/stmmac/stmmac_main.c |    1 -
 1 files changed, 0 insertions(+), 1 deletions(-)

diff --git a/drivers/net/stmmac/stmmac_main.c b/drivers/net/stmmac/stmmac_main.c
index 0bdd332..1083334 100644
--- a/drivers/net/stmmac/stmmac_main.c
+++ b/drivers/net/stmmac/stmmac_main.c
@@ -829,7 +829,6 @@ static int stmmac_open(struct net_device *dev)
 	 * In case of failure continue without timer. */
 	if (unlikely((stmmac_open_ext_timer(dev, priv->tm)) < 0)) {
 		pr_warning("stmmaceth: cannot attach the external timer.\n");
-		tmrate = 0;
 		priv->tm->freq = 0;
 		priv->tm->timer_start = stmmac_no_timer_started;
 		priv->tm->timer_stop = stmmac_no_timer_stopped;
-- 
1.5.5.6

