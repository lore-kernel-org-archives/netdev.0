From: "Gustavo A. R. Silva" <garsilva@embeddedor.com>
Subject: [PATCH] net: smc_close: mark expected switch fall-throughs
Date: Thu, 19 Oct 2017 17:02:44 -0500
Message-ID: <20171019220244.GA22041@embeddedor.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-s390@vger.kernel.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org,
        "Gustavo A. R. Silva" <garsilva@embeddedor.com>
To: Ursula Braun <ubraun@linux.vnet.ibm.com>,
        "David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

In preparation to enabling -Wimplicit-fallthrough, mark switch cases
where we are expecting to fall through.

Notice that in this particular case I placed a "fall through" comment on
its own line, which is what GCC is expecting to find.

Signed-off-by: Gustavo A. R. Silva <garsilva@embeddedor.com>
---
 net/smc/smc_close.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/net/smc/smc_close.c b/net/smc/smc_close.c
index f0d16fb..9b16f40 100644
--- a/net/smc/smc_close.c
+++ b/net/smc/smc_close.c
@@ -360,7 +360,8 @@ static void smc_close_passive_work(struct work_struct *work)
 	case SMC_PEERCLOSEWAIT1:
 		if (rxflags->peer_done_writing)
 			sk->sk_state = SMC_PEERCLOSEWAIT2;
-		/* fall through to check for closing */
+		/* to check for closing */
+		/* fall through */
 	case SMC_PEERCLOSEWAIT2:
 	case SMC_PEERFINCLOSEWAIT:
 		if (!smc_cdc_rxed_any_close(&smc->conn))
-- 
2.7.4
