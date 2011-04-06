From: Mahesh Bandewar <maheshb@google.com>
Subject: [PATCH 06/20] net-decnet: extending (hw_/wanted_/vlan_)features fields to a bitmap.
Date: Tue,  5 Apr 2011 17:44:11 -0700
Message-ID: <1302050665-10460-7-git-send-email-maheshb@google.com>
References: <1302050665-10460-1-git-send-email-maheshb@google.com>
 <1302050665-10460-2-git-send-email-maheshb@google.com>
 <1302050665-10460-3-git-send-email-maheshb@google.com>
 <1302050665-10460-4-git-send-email-maheshb@google.com>
 <1302050665-10460-5-git-send-email-maheshb@google.com>
 <1302050665-10460-6-git-send-email-maheshb@google.com>
Cc: netdev <netdev@vger.kernel.org>,
	Mahesh Bandewar <maheshb@google.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([74.125.121.67]:28063 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754171Ab1DFAoz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Apr 2011 20:44:55 -0400
In-Reply-To: <1302050665-10460-6-git-send-email-maheshb@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Converting current use of (hw_/wanted_/vlan_)features to
legacy_(hw_/wanted_/vlan_)features to differntiate from the proposed usage.

Signed-off-by: Mahesh Bandewar <maheshb@google.com>
---
 net/decnet/af_decnet.c  |    2 +-
 net/decnet/dn_nsp_out.c |    2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/decnet/af_decnet.c b/net/decnet/af_decnet.c
index ea3b6ee..5f0a6f9 100644
--- a/net/decnet/af_decnet.c
+++ b/net/decnet/af_decnet.c
@@ -955,7 +955,7 @@ static int __dn_connect(struct sock *sk, struct sockaddr_dn *addr, int addrlen,
 	fld.flowidn_proto = DNPROTO_NSP;
 	if (dn_route_output_sock(&sk->sk_dst_cache, &fld, sk, flags) < 0)
 		goto out;
-	sk->sk_route_caps = sk->sk_dst_cache->dev->features;
+	sk->sk_route_caps = sk->sk_dst_cache->dev->legacy_features;
 	sock->state = SS_CONNECTING;
 	scp->state = DN_CI;
 	scp->segsize_loc = dst_metric_advmss(sk->sk_dst_cache);
diff --git a/net/decnet/dn_nsp_out.c b/net/decnet/dn_nsp_out.c
index bd78836..4f70026 100644
--- a/net/decnet/dn_nsp_out.c
+++ b/net/decnet/dn_nsp_out.c
@@ -99,7 +99,7 @@ try_again:
 	fld.flowidn_proto = DNPROTO_NSP;
 	if (dn_route_output_sock(&sk->sk_dst_cache, &fld, sk, 0) == 0) {
 		dst = sk_dst_get(sk);
-		sk->sk_route_caps = dst->dev->features;
+		sk->sk_route_caps = dst->dev->legacy_features;
 		goto try_again;
 	}
 
-- 
1.7.3.1

