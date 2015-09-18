From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 4/4] netfilter: nf_log: wait for rcu grace after logger unregistration
Date: Fri, 18 Sep 2015 11:17:56 +0200
Message-ID: <1442567876-4046-5-git-send-email-pablo@netfilter.org>
References: <1442567876-4046-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1442567876-4046-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The nf_log_unregister() function needs to call synchronize_rcu() to make sure
that the objects are not dereferenced anymore on module removal.

Fixes: 5962815a6a56 ("netfilter: nf_log: use an array of loggers instead of list")
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/netfilter/nf_log.c |    1 +
 1 file changed, 1 insertion(+)

diff --git a/net/netfilter/nf_log.c b/net/netfilter/nf_log.c
index a5ebd7d..a5d41df 100644
--- a/net/netfilter/nf_log.c
+++ b/net/netfilter/nf_log.c
@@ -117,6 +117,7 @@ void nf_log_unregister(struct nf_logger *logger)
 			RCU_INIT_POINTER(loggers[i][logger->type], NULL);
 	}
 	mutex_unlock(&nf_log_mutex);
+	synchronize_rcu();
 }
 EXPORT_SYMBOL(nf_log_unregister);
 
-- 
1.7.10.4

