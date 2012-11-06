From: Krzysztof Mazur <krzysiek@podlesie.net>
Subject: [PATCH v3 7/7] pppoatm: do not inline pppoatm_may_send()
Date: Tue,  6 Nov 2012 23:17:02 +0100
Message-ID: <1352240222-363-8-git-send-email-krzysiek@podlesie.net>
References: <1352240222-363-1-git-send-email-krzysiek@podlesie.net>
Cc: linux-kernel@vger.kernel.org,
	Chas Williams - CONTRACTOR <chas@cmf.nrl.navy.mil>,
	David Woodhouse <David.Woodhouse@intel.com>,
	davem@davemloft.net, Krzysztof Mazur <krzysiek@podlesie.net>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1352240222-363-1-git-send-email-krzysiek@podlesie.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The pppoatm_may_send() is quite heavy and it's called three times
in pppoatm_send() and inlining costs more than 200 bytes of code
(more than 10% of total pppoatm driver code size).

add/remove: 1/0 grow/shrink: 0/1 up/down: 132/-367 (-235)
function                                     old     new   delta
pppoatm_may_send                               -     132    +132
pppoatm_send                                 900     533    -367

Signed-off-by: Krzysztof Mazur <krzysiek@podlesie.net>
---
 net/atm/pppoatm.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/atm/pppoatm.c b/net/atm/pppoatm.c
index bf5d6c9..7507c20 100644
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
1.8.0.233.g54991f2
