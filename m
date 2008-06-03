From: Jesper Dangaard Brouer <jdb@comx.dk>
Subject: [PATCH 1/2] HTB scheduler, change default hysteresis mode to off.
Date: Tue, 03 Jun 2008 16:05:07 +0200
Message-ID: <1212501907.13164.30.camel@localhost.localdomain>
References: <1212501803.13164.27.camel@localhost.localdomain>
Reply-To: jdb@comx.dk
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Martin Devera <devik@cdi.cz>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from lanfw001a.cxnet.dk ([87.72.215.196]:56445 "EHLO
	lanfw001a.cxnet.dk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752662AbYFCObN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Jun 2008 10:31:13 -0400
In-Reply-To: <1212501803.13164.27.camel@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


The HTB hysteresis mode reduce the CPU load, but at the
cost of scheduling accuracy.

On ADSL links (512 kbit/s upstream), this inaccuracy introduce
significant jitter, enought to disturbe VoIP.  For details see my
masters thesis (http://www.adsl-optimizer.dk/thesis/), chapter 7,
section 7.3.1, pp 69-70.

Signed-off-by: Jesper Dangaard Brouer <hawk@comx.dk>
---
 net/sched/sch_htb.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/sched/sch_htb.c b/net/sched/sch_htb.c
index 5bc1ed4..9134f02 100644
--- a/net/sched/sch_htb.c
+++ b/net/sched/sch_htb.c
@@ -53,7 +53,7 @@
 */
 
 #define HTB_HSIZE 16		/* classid hash size */
-#define HTB_HYSTERESIS 1	/* whether to use mode hysteresis for speedup */
+#define HTB_HYSTERESIS 0	/* whether to use mode hysteresis for speedup */
 #define HTB_VER 0x30011		/* major must be matched with number suplied by TC as version */
 
 #if HTB_VER >> 16 != TC_HTB_PROTOVER
-- 
1.5.4.2


