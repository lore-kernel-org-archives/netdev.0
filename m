From: Patrick McHardy <kaber@trash.net>
Subject: netfilter 18/29: nfnetlink_log: fix warning and prototype mismatch
Date: Thu, 27 Nov 2008 17:15:27 +0100 (MET)
Message-ID: <20081127161527.13891.18626.sendpatchset@x2.localnet>
References: <20081127161503.13891.62766.sendpatchset@x2.localnet>
Cc: netdev@vger.kernel.org, Patrick McHardy <kaber@trash.net>,
	netfilter-devel@vger.kernel.org
To: davem@davemloft.net
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20081127161503.13891.62766.sendpatchset@x2.localnet>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

commit d9e150071d18b5c87ba7a097af4063a5ad0c6a0c
Author: Patrick McHardy <kaber@trash.net>
Date:   Tue Nov 18 12:16:52 2008 +0100

    netfilter: nfnetlink_log: fix warning and prototype mismatch
    
    net/netfilter/nfnetlink_log.c:537:1: warning: symbol 'nfulnl_log_packet' was not declared. Should it be static?
    
    Including the proper header also revealed an incorrect prototype.
    
    Signed-off-by: Patrick McHardy <kaber@trash.net>

diff --git a/include/net/netfilter/nfnetlink_log.h b/include/net/netfilter/nfnetlink_log.h
index 9b67f94..b0569ff 100644
--- a/include/net/netfilter/nfnetlink_log.h
+++ b/include/net/netfilter/nfnetlink_log.h
@@ -2,7 +2,7 @@
 #define _KER_NFNETLINK_LOG_H
 
 void
-nfulnl_log_packet(unsigned int pf,
+nfulnl_log_packet(u_int8_t pf,
 		  unsigned int hooknum,
 		  const struct sk_buff *skb,
 		  const struct net_device *in,
diff --git a/net/netfilter/nfnetlink_log.c b/net/netfilter/nfnetlink_log.c
index a51892b..2770b4e 100644
--- a/net/netfilter/nfnetlink_log.c
+++ b/net/netfilter/nfnetlink_log.c
@@ -30,6 +30,7 @@
 #include <linux/random.h>
 #include <net/sock.h>
 #include <net/netfilter/nf_log.h>
+#include <net/netfilter/nfnetlink_log.h>
 
 #include <asm/atomic.h>
 
