From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 4/6] netfilter: nfnetlink: validate nfnetlink header from batch
Date: Sat, 10 Jan 2015 19:50:06 +0100
Message-ID: <1420915808-7160-5-git-send-email-pablo@netfilter.org>
References: <1420915808-7160-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:46768 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754172AbbAJSrY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 10 Jan 2015 13:47:24 -0500
In-Reply-To: <1420915808-7160-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Make sure there is enough room for the nfnetlink header in the
netlink messages that are part of the batch. There is a similar
check in netlink_rcv_skb().

Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/netfilter/nfnetlink.c |    3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/net/netfilter/nfnetlink.c b/net/netfilter/nfnetlink.c
index 13c2e17..c6619d4 100644
--- a/net/netfilter/nfnetlink.c
+++ b/net/netfilter/nfnetlink.c
@@ -321,7 +321,8 @@ replay:
 		nlh = nlmsg_hdr(skb);
 		err = 0;
 
-		if (nlh->nlmsg_len < NLMSG_HDRLEN) {
+		if (nlmsg_len(nlh) < sizeof(struct nfgenmsg) ||
+		    skb->len < nlh->nlmsg_len) {
 			err = -EINVAL;
 			goto ack;
 		}
-- 
1.7.10.4
