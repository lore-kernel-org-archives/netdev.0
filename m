From: Patrick McHardy <kaber@trash.net>
Subject: netfilter -stable 03/04: bridge: refcount fix
Date: Thu, 17 Sep 2009 13:58:29 +0200 (MEST)
Message-ID: <20090917115827.12728.41214.sendpatchset@x2.localnet>
References: <20090917115823.12728.87778.sendpatchset@x2.localnet>
Cc: netdev@vger.kernel.org, Patrick McHardy <kaber@trash.net>,
	netfilter-devel@vger.kernel.org, davem@davemloft.net
To: stable@kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20090917115823.12728.87778.sendpatchset@x2.localnet>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

commit 9f3150b57714f4e22c5f34eef484f1b38bb811b0
Author: Patrick McHardy <kaber@trash.net>
Date:   Thu Sep 17 13:30:49 2009 +0200

    netfilter: bridge: refcount fix
    
    Upstream commit f3abc9b9:
    
    commit f216f082b2b37c4943f1e7c393e2786648d48f6f
    ([NETFILTER]: bridge netfilter: deal with martians correctly)
    added a refcount leak on in_dev.
    
    Instead of using in_dev_get(), we can use __in_dev_get_rcu(),
    as netfilter hooks are running under rcu_read_lock(), as pointed
    by Patrick.
    
    Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
    Signed-off-by: Patrick McHardy <kaber@trash.net>

diff --git a/net/bridge/br_netfilter.c b/net/bridge/br_netfilter.c
index d22f611..991fe40 100644
--- a/net/bridge/br_netfilter.c
+++ b/net/bridge/br_netfilter.c
@@ -359,7 +359,7 @@ static int br_nf_pre_routing_finish(struct sk_buff *skb)
 				},
 				.proto = 0,
 			};
-			struct in_device *in_dev = in_dev_get(dev);
+			struct in_device *in_dev = __in_dev_get_rcu(dev);
 
 			/* If err equals -EHOSTUNREACH the error is due to a
 			 * martian destination or due to the fact that
