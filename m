From: DDD <Dongdong.deng@windriver.com>
Subject: [PATCH 1/2] netpoll: warning for ndo_start_xmit returns with
	interrupts enabled
Date: Fri, 21 Aug 2009 21:33:36 +0800
Message-ID: <1250861616.24178.20.camel@dengdd-desktop>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: lkml <linux-kernel@vger.kernel.org>, netdev@vger.kernel.org,
	Jason Wessel <jason.wessel@windriver.com>
To: Matt Mackall <mpm@selenic.com>, David Miller <davem@davemloft.net>,
	Nicolas Pitre <nico@cam.org>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1755167AbZHUNVf@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

WARN_ONCE for ndo_start_xmit() enable interrupts in netpoll_send_skb(),
because the NETPOLL API requires that interrupts remain disabled in
netpoll_send_skb().

Signed-off-by: Dongdong Deng <dongdong.deng@windriver.com>
---
 net/core/netpoll.c |    5 +++++
 1 files changed, 5 insertions(+), 0 deletions(-)

diff --git a/net/core/netpoll.c b/net/core/netpoll.c
index df30feb..1b76eb1 100644
--- a/net/core/netpoll.c
+++ b/net/core/netpoll.c
@@ -319,6 +319,11 @@ static void netpoll_send_skb(struct netpoll *np, struct sk_buff *skb)
 
 			udelay(USEC_PER_POLL);
 		}
+
+		WARN_ONCE(!irqs_disabled(),
+			"netpoll_send_skb(): %s enabled interrupts in poll (%pF)\n",
+			dev->name, ops->ndo_start_xmit);
+
 		local_irq_restore(flags);
 	}
 
-- 
1.6.0.4
