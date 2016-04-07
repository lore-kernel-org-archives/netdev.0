From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: [PATCH net-next] sock: make lockdep_sock_is_held static inline
Date: Thu,  7 Apr 2016 23:53:35 +0200
Message-ID: <1460066015-22105-1-git-send-email-hannes@stressinduktion.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from out5-smtp.messagingengine.com ([66.111.4.29]:34482 "EHLO
	out5-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751934AbcDGVxo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Apr 2016 17:53:44 -0400
Received: from compute6.internal (compute6.nyi.internal [10.202.2.46])
	by mailout.nyi.internal (Postfix) with ESMTP id 00B1520A81
	for <netdev@vger.kernel.org>; Thu,  7 Apr 2016 17:53:43 -0400 (EDT)
Received: from z.localhost.localdomain (unknown [213.55.184.139])
	by mail.messagingengine.com (Postfix) with ESMTPA id 4F30DC00013
	for <netdev@vger.kernel.org>; Thu,  7 Apr 2016 17:53:43 -0400 (EDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I forgot to add inline to lockdep_sock_is_held, so it generated all
kinds of build warnings if not build with lockdep support.

Reported-by: kbuild test robot <fengguang.wu@intel.com>
Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
---
 include/net/sock.h | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/include/net/sock.h b/include/net/sock.h
index eb2d7c3e120b25..46b29374df8ed7 100644
--- a/include/net/sock.h
+++ b/include/net/sock.h
@@ -1360,7 +1360,7 @@ do {									\
 	lockdep_init_map(&(sk)->sk_lock.dep_map, (name), (key), 0);	\
 } while (0)
 
-static bool lockdep_sock_is_held(const struct sock *csk)
+static inline bool lockdep_sock_is_held(const struct sock *csk)
 {
 	struct sock *sk = (struct sock *)csk;
 
-- 
2.5.5
