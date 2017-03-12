From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: [PATCH net-next RFC v1 09/27] afnetns: add sock_afnetns
Date: Mon, 13 Mar 2017 00:01:33 +0100
Message-ID: <20170312230151.5185-10-hannes@stressinduktion.org>
References: <20170312230151.5185-1-hannes@stressinduktion.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from out1-smtp.messagingengine.com ([66.111.4.25]:52377 "EHLO
        out1-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S935601AbdCLXCI (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 12 Mar 2017 19:02:08 -0400
Received: from compute7.internal (compute7.nyi.internal [10.202.2.47])
        by mailout.nyi.internal (Postfix) with ESMTP id 24C6120753
        for <netdev@vger.kernel.org>; Sun, 12 Mar 2017 19:02:00 -0400 (EDT)
Received: from m.localhost.localhost (unknown [213.55.211.72])
        by mail.messagingengine.com (Postfix) with ESMTPA id 85E822423E
        for <netdev@vger.kernel.org>; Sun, 12 Mar 2017 19:01:59 -0400 (EDT)
In-Reply-To: <20170312230151.5185-1-hannes@stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
---
 include/net/sock.h | 9 +++++++++
 1 file changed, 9 insertions(+)

diff --git a/include/net/sock.h b/include/net/sock.h
index 1e05d497db2520..aa204bf3537ba0 100644
--- a/include/net/sock.h
+++ b/include/net/sock.h
@@ -2293,6 +2293,15 @@ struct net *sock_net(const struct sock *sk)
 	return read_pnet(&sk->sk_net);
 }
 
+static inline struct afnetns *sock_afnetns(const struct sock *sk)
+{
+#if IS_ENABLED(CONFIG_AFNETNS)
+	return sk->sk_afnet;
+#else
+	return NULL;
+#endif
+}
+
 static inline
 void sock_net_set(struct sock *sk, struct net *net)
 {
-- 
2.9.3
