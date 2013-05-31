From: Simon Horman <horms@verge.net.au>
Subject: [PATCH net-next] sctp: Correct byte order of access to skb->{network, transport}_header
Date: Fri, 31 May 2013 15:36:11 +0900
Message-ID: <1369982171-22317-1-git-send-email-horms@verge.net.au>
Cc: netdev@vger.kernel.org, netfilter-devel@vger.kernel.org,
	Ben Hutchings <bhutchings@solarflare.com>,
	Simon Horman <horms@verge.net.au>
To: Pablo Neira Ayuso <pablo@netfilter.org>,
	David Miller <davem@davemloft.net>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Corrects an byte order conflict introduced by "sctp: Correct access to
skb->{network, transport}_header". All the values in question are host
byte order.

Reported-by: Ben Hutchings <bhutchings@solarflare.com>
Signed-off-by: Simon Horman <horms@verge.net.au>
---
 net/sctp/input.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/sctp/input.c b/net/sctp/input.c
index e328fe8..6533d81 100644
--- a/net/sctp/input.c
+++ b/net/sctp/input.c
@@ -589,7 +589,7 @@ void sctp_v4_err(struct sk_buff *skb, __u32 info)
 	struct sctp_association *asoc = NULL;
 	struct sctp_transport *transport;
 	struct inet_sock *inet;
-	__be16 saveip, savesctp;
+	__u16 saveip, savesctp;
 	int err;
 	struct net *net = dev_net(skb->dev);
 
-- 
1.7.10.4

