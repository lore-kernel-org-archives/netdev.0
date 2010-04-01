From: Hagen Paul Pfeifer <hagen@jauu.net>
Subject: [PATCH] ipv4: remove redundant verification code
Date: Thu,  1 Apr 2010 02:54:46 +0200
Message-ID: <1270083286-25332-1-git-send-email-hagen@jauu.net>
Cc: davem@davemloft.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from alternativer.internetendpunkt.de ([88.198.24.89]:44937 "EHLO
	geheimer.internetendpunkt.de" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1756598Ab0DAAyt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 31 Mar 2010 20:54:49 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The check if error signaling is wanted (inet->recverr != 0) is done by
the caller: raw.c:raw_err() and udp.c:__udp4_lib_err(), so there is no
need to check this condition again.

Signed-off-by: Hagen Paul Pfeifer <hagen@jauu.net>
---
 net/ipv4/ip_sockglue.c |    4 ----
 1 files changed, 0 insertions(+), 4 deletions(-)

diff --git a/net/ipv4/ip_sockglue.c b/net/ipv4/ip_sockglue.c
index 644dc43..f4b47ac 100644
--- a/net/ipv4/ip_sockglue.c
+++ b/net/ipv4/ip_sockglue.c
@@ -286,12 +286,8 @@ int ip_ra_control(struct sock *sk, unsigned char on,
 void ip_icmp_error(struct sock *sk, struct sk_buff *skb, int err,
 		   __be16 port, u32 info, u8 *payload)
 {
-	struct inet_sock *inet = inet_sk(sk);
 	struct sock_exterr_skb *serr;
 
-	if (!inet->recverr)
-		return;
-
 	skb = skb_clone(skb, GFP_ATOMIC);
 	if (!skb)
 		return;
-- 
1.6.6.196.g1f735.dirty

