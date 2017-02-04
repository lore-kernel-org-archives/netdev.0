From: Eric Dumazet <edumazet@google.com>
Subject: [PATCH v2 net-next 11/12] aeroflex/greth: use napi_complete_done()
Date: Sat,  4 Feb 2017 15:25:01 -0800
Message-ID: <20170204232502.22361-12-edumazet@google.com>
References: <20170204232502.22361-1-edumazet@google.com>
Cc: netdev <netdev@vger.kernel.org>,
        Eric Dumazet <edumazet@google.com>,
        Eric Dumazet <eric.dumazet@gmail.com>
To: "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f174.google.com ([209.85.192.174]:35775 "EHLO
        mail-pf0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751803AbdBDXZz (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 4 Feb 2017 18:25:55 -0500
Received: by mail-pf0-f174.google.com with SMTP id f144so14409236pfa.2
        for <netdev@vger.kernel.org>; Sat, 04 Feb 2017 15:25:35 -0800 (PST)
In-Reply-To: <20170204232502.22361-1-edumazet@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We plan to remove __napi_complete() soon,
this driver is the last user.

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 drivers/net/ethernet/aeroflex/greth.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/aeroflex/greth.c b/drivers/net/ethernet/aeroflex/greth.c
index 93def92f999703d234b44508725f45863ef3..9f7422ada704e9484b79d336ece46a054766 100644
--- a/drivers/net/ethernet/aeroflex/greth.c
+++ b/drivers/net/ethernet/aeroflex/greth.c
@@ -1008,7 +1008,7 @@ static int greth_poll(struct napi_struct *napi, int budget)
 			spin_unlock_irqrestore(&greth->devlock, flags);
 			goto restart_txrx_poll;
 		} else {
-			__napi_complete(napi);
+			napi_complete_done(napi, work_done);
 			spin_unlock_irqrestore(&greth->devlock, flags);
 		}
 	}
-- 
2.11.0.483.g087da7b7c-goog
