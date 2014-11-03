From: Guenter Roeck <linux@roeck-us.net>
Subject: [PATCH] netfilter: nft_reject_bridge: Fix powerpc build error
Date: Sun,  2 Nov 2014 18:19:15 -0800
Message-ID: <1414981155-27155-1-git-send-email-linux@roeck-us.net>
Cc: "David S. Miller" <davem@davemloft.net>,
	netfilter-devel@vger.kernel.org, coreteam@netfilter.org,
	bridge@lists.linux-foundation.org, netdev@vger.kernel.org,
	Stephen Hemminger <stephen@networkplumber.org>,
	Guenter Roeck <linux@roeck-us.net>,
	Pablo Neira Ayuso <pablo@netfilter.org>
To: Patrick McHardy <kaber@trash.net>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Fix:
net/bridge/netfilter/nft_reject_bridge.c:
In function 'nft_reject_br_send_v6_unreach':
net/bridge/netfilter/nft_reject_bridge.c:240:3:
	error: implicit declaration of function 'csum_ipv6_magic'
   csum_ipv6_magic(&nip6h->saddr, &nip6h->daddr,
   ^
make[3]: *** [net/bridge/netfilter/nft_reject_bridge.o] Error 1

Seen with powerpc:allmodconfig.

Fixes: 523b929d5446 ("netfilter: nft_reject_bridge: don't use IP stack to reject traffic")
Cc: Pablo Neira Ayuso <pablo@netfilter.org>
Signed-off-by: Guenter Roeck <linux@roeck-us.net>
---
 net/bridge/netfilter/nft_reject_bridge.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/net/bridge/netfilter/nft_reject_bridge.c b/net/bridge/netfilter/nft_reject_bridge.c
index 654c901..48da2c5 100644
--- a/net/bridge/netfilter/nft_reject_bridge.c
+++ b/net/bridge/netfilter/nft_reject_bridge.c
@@ -18,6 +18,7 @@
 #include <net/netfilter/ipv6/nf_reject.h>
 #include <linux/ip.h>
 #include <net/ip.h>
+#include <net/ip6_checksum.h>
 #include <linux/netfilter_bridge.h>
 #include "../br_private.h"
 
-- 
1.9.1

