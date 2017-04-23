From: Pan Bian <bianpan2016@163.com>
Subject: [PATCH 1/1] lwtunnel: check return value of nla_nest_start
Date: Sun, 23 Apr 2017 14:28:37 +0800
Message-ID: <1492928917-25628-1-git-send-email-bianpan2016@163.com>
Cc: David Ahern <dsa@cumulusnetworks.com>,
        Roopa Prabhu <roopa@cumulusnetworks.com>,
        Alexei Starovoitov <ast@kernel.org>,
        David Lebrun <david.lebrun@uclouvain.be>,
        Tom Herbert <tom@herbertland.com>,
        Robert Shearman <rshearma@brocade.com>, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, Pan Bian <bianpan2016@163.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from m50-134.163.com ([123.125.50.134]:41077 "EHLO m50-134.163.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S933481AbdDWG31 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sun, 23 Apr 2017 02:29:27 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Function nla_nest_start() may return a NULL pointer on error. However,
in function lwtunnel_fill_encap(), the return value of nla_nest_start()
is not validated before it is used. This patch checks the return value
of nla_nest_start() against NULL.

Signed-off-by: Pan Bian <bianpan2016@163.com>
---
 net/core/lwtunnel.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/net/core/lwtunnel.c b/net/core/lwtunnel.c
index 6df9f8f..3471ce7 100644
--- a/net/core/lwtunnel.c
+++ b/net/core/lwtunnel.c
@@ -216,6 +216,8 @@ int lwtunnel_fill_encap(struct sk_buff *skb, struct lwtunnel_state *lwtstate)
 
 	ret = -EOPNOTSUPP;
 	nest = nla_nest_start(skb, RTA_ENCAP);
+	if (!nest)
+		goto nla_put_failure;
 	rcu_read_lock();
 	ops = rcu_dereference(lwtun_encaps[lwtstate->type]);
 	if (likely(ops && ops->fill_encap))
-- 
1.9.1
