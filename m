From: fgao@ikuai8.com
Subject: [PATCH nf-next] netfilter: log: Check param to avoid overflow in nf_log_set
Date: Sun, 28 Aug 2016 22:30:18 +0800
Message-ID: <1472394618-5711-1-git-send-email-fgao@ikuai8.com>
Cc: gfree.wind@gmail.com, Gao Feng <fgao@ikuai8.com>
To: pablo@netfilter.org, kaber@trash.net, davem@davemloft.net,
        netfilter-devel@vger.kernel.org, coreteam@netfilter.org,
        netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from SMTPBG132.QQ.COM ([113.108.23.42]:53490 "EHLO smtpbg132.qq.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752371AbcH1Oc2 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sun, 28 Aug 2016 10:32:28 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Gao Feng <fgao@ikuai8.com>

The nf_log_set is an interface function, so it should do the strict sanity
check of parameters. Add  one sanity check for pf, it could not exceed
NFPROTO_NUMPROTO, and print error log when pf is invalid.

Signed-off-by: Gao Feng <fgao@ikuai8.com>
---
 net/netfilter/nf_log.c | 4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/net/netfilter/nf_log.c b/net/netfilter/nf_log.c
index aa5847a..02ce0b9 100644
--- a/net/netfilter/nf_log.c
+++ b/net/netfilter/nf_log.c
@@ -43,8 +43,10 @@ void nf_log_set(struct net *net, u_int8_t pf, const struct nf_logger *logger)
 {
 	const struct nf_logger *log;
 
-	if (pf == NFPROTO_UNSPEC)
+	if (pf == NFPROTO_UNSPEC || pf >= NFPROTO_NUMPROTO) {
+		pr_err("Wrong pf(%d) for nf log", pf);
 		return;
+	}
 
 	mutex_lock(&nf_log_mutex);
 	log = nft_log_dereference(net->nf.nf_loggers[pf]);
-- 
1.9.1
