From: Paolo Abeni <pabeni@redhat.com>
Subject: [PATCH net] udp: unbreak build lacking CONFIG_XFRM
Date: Wed, 26 Jul 2017 11:33:49 +0200
Message-ID: <b8448ef348e62558d3ab92468e1e5ed076d66afe.1501061474.git.pabeni@redhat.com>
References: <201707260327.pfv8cNFg%fengguang.wu@intel.com>
Cc: "David S. Miller" <davem@davemloft.net>,
        Paul Moore <paul@paul-moore.com>, kbuild-all@01.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:39368 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751540AbdGZJfC (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 26 Jul 2017 05:35:02 -0400
In-Reply-To: <201707260327.pfv8cNFg%fengguang.wu@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We must use pre-processor conditional block or suitable accessors to
manipulate skb->sp elsewhere builds lacking the CONFIG_XFRM will break.

Fixes: dce4551cb2ad ("udp: preserve head state for IP_CMSG_PASSSEC")
Signed-off-by: Paolo Abeni <pabeni@redhat.com>
---
 net/ipv4/udp.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/ipv4/udp.c b/net/ipv4/udp.c
index d243772f6efc..fac7cb9e3b0f 100644
--- a/net/ipv4/udp.c
+++ b/net/ipv4/udp.c
@@ -1786,7 +1786,7 @@ static int __udp_queue_rcv_skb(struct sock *sk, struct sk_buff *skb)
 	 * the IP options and the cmsg flags, elsewhere can we clear all
 	 * pending head states while they are hot in the cache
 	 */
-	if (likely(IPCB(skb)->opt.optlen == 0 && !skb->sp))
+	if (likely(IPCB(skb)->opt.optlen == 0 && !skb_sec_path(skb)))
 		skb_release_head_state(skb);
 
 	rc = __udp_enqueue_schedule_skb(sk, skb);
-- 
2.13.3
