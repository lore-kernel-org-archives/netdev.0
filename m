From: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Subject: [PATCH net 2/2] net/sock: add WARN_ON(parent->sk) in sock_graft()
Date: Thu,  6 Jul 2017 08:15:07 -0700
Message-ID: <2cde1d0be5766abbc90a9e74db4073cc1c418bc2.1499352757.git.sowmini.varadhan@oracle.com>
References: <cover.1499352757.git.sowmini.varadhan@oracle.com>
Cc: davem@davemloft.net, sowmini.varadhan@oracle.com,
        santosh.shilimkar@oracle.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:45619 "EHLO
        userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751742AbdGFPR5 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 6 Jul 2017 11:17:57 -0400
In-Reply-To: <cover.1499352757.git.sowmini.varadhan@oracle.com>
In-Reply-To: <cover.1499352757.git.sowmini.varadhan@oracle.com>
References: <cover.1499352757.git.sowmini.varadhan@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

sock_graft() unilaterally sets up parent->sk based on the
assumption that the existing parent->sk is null. If this
condition is not true, then the existing parent->sk would
be leaked, so add a WARN_ON() to alert callers who may fall
in this category.

Signed-off-by: Sowmini Varadhan <sowmini.varadhan@oracle.com>
---
 include/net/sock.h |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/include/net/sock.h b/include/net/sock.h
index 48e4d5c..8c85791 100644
--- a/include/net/sock.h
+++ b/include/net/sock.h
@@ -1697,6 +1697,7 @@ static inline void sock_orphan(struct sock *sk)
 
 static inline void sock_graft(struct sock *sk, struct socket *parent)
 {
+	WARN_ON(parent->sk);
 	write_lock_bh(&sk->sk_callback_lock);
 	sk->sk_wq = parent->wq;
 	parent->sk = sk;
-- 
1.7.1
