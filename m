From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 4/4] netfilter: xt_TCPMSS: correct return value in tcpmss_mangle_packet
Date: Wed,  4 Sep 2013 15:00:25 +0200
Message-ID: <1378299625-4638-5-git-send-email-pablo@netfilter.org>
References: <1378299625-4638-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1378299625-4638-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Phil Oester <kernel@linuxace.com>

In commit b396966c4 (netfilter: xt_TCPMSS: Fix missing fragmentation handling),
I attempted to add safe fragment handling to xt_TCPMSS.  However, Andy Padavan
of Project N56U correctly points out that returning XT_CONTINUE in this
function does not work.  The callers (tcpmss_tg[46]) expect to receive a value
of 0 in order to return XT_CONTINUE.

Signed-off-by: Phil Oester <kernel@linuxace.com>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/netfilter/xt_TCPMSS.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/netfilter/xt_TCPMSS.c b/net/netfilter/xt_TCPMSS.c
index 6113cc7..cd24290 100644
--- a/net/netfilter/xt_TCPMSS.c
+++ b/net/netfilter/xt_TCPMSS.c
@@ -60,7 +60,7 @@ tcpmss_mangle_packet(struct sk_buff *skb,
 
 	/* This is a fragment, no TCP header is available */
 	if (par->fragoff != 0)
-		return XT_CONTINUE;
+		return 0;
 
 	if (!skb_make_writable(skb, skb->len))
 		return -1;
-- 
1.7.10.4

