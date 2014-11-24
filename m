From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 08/17] netfilter: nf_log: fix sparse warning in nf_logger_find_get()
Date: Mon, 24 Nov 2014 14:27:45 +0100
Message-ID: <1416835674-11871-9-git-send-email-pablo@netfilter.org>
References: <1416835674-11871-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:44871 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932103AbaKXNZ4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 24 Nov 2014 08:25:56 -0500
In-Reply-To: <1416835674-11871-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

net/netfilter/nf_log.c:157:16: warning: incorrect type in assignment (different address spaces)
net/netfilter/nf_log.c:157:16:    expected struct nf_logger *logger
net/netfilter/nf_log.c:157:16:    got struct nf_logger [noderef] <asn:4>*<noident>

Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/netfilter/nf_log.c |    3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/net/netfilter/nf_log.c b/net/netfilter/nf_log.c
index 9562e39..49a6417 100644
--- a/net/netfilter/nf_log.c
+++ b/net/netfilter/nf_log.c
@@ -154,8 +154,7 @@ int nf_logger_find_get(int pf, enum nf_log_type type)
 	struct nf_logger *logger;
 	int ret = -ENOENT;
 
-	logger = loggers[pf][type];
-	if (logger == NULL)
+	if (rcu_access_pointer(loggers[pf][type]) == NULL)
 		request_module("nf-logger-%u-%u", pf, type);
 
 	rcu_read_lock();
-- 
1.7.10.4
