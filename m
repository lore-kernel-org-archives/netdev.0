From: David Woodhouse <dwmw2@infradead.org>
Subject: [PATCH 06/17] pppoatm: do not inline pppoatm_may_send()
Date: Fri, 30 Nov 2012 00:35:25 +0000
Message-ID: <1354235736-26833-7-git-send-email-dwmw2@infradead.org>
References: <1354235736-26833-1-git-send-email-dwmw2@infradead.org>
Cc: chas@cmf.nrl.navy.mil, krzysiek@podlesie.net,
	David Woodhouse <David.Woodhouse@intel.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from merlin.infradead.org ([205.233.59.134]:37527 "EHLO
	merlin.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755279Ab2K3Agn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 Nov 2012 19:36:43 -0500
In-Reply-To: <1354235736-26833-1-git-send-email-dwmw2@infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Krzysztof Mazur <krzysiek@podlesie.net>

The pppoatm_may_send() is quite heavy and it's called three times
in pppoatm_send() and inlining costs more than 200 bytes of code
(more than 10% of total pppoatm driver code size).

add/remove: 1/0 grow/shrink: 0/1 up/down: 132/-367 (-235)
function                                     old     new   delta
pppoatm_may_send                               -     132    +132
pppoatm_send                                 900     533    -367

Signed-off-by: Krzysztof Mazur <krzysiek@podlesie.net>
Signed-off-by: David Woodhouse <David.Woodhouse@intel.com>
---
 net/atm/pppoatm.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/atm/pppoatm.c b/net/atm/pppoatm.c
index aeb726c..3dce84a 100644
--- a/net/atm/pppoatm.c
+++ b/net/atm/pppoatm.c
@@ -214,7 +214,7 @@ error:
 	ppp_input_error(&pvcc->chan, 0);
 }
 
-static inline int pppoatm_may_send(struct pppoatm_vcc *pvcc, int size)
+static int pppoatm_may_send(struct pppoatm_vcc *pvcc, int size)
 {
 	/*
 	 * It's not clear that we need to bother with using atm_may_send()
-- 
1.8.0
