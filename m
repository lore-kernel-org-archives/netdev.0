From: Aaron Conole <aconole@bytheb.org>
Subject: [PATCH v4 1/2] [net] af_unix: Convert the unix_sk macro to an inline function for type safety
Date: Sat, 26 Sep 2015 18:50:42 -0400
Message-ID: <1443307843-16880-2-git-send-email-aconole@bytheb.org>
References: <20150924.121459.1016780653505420756.davem@davemloft.net>
 <1443307843-16880-1-git-send-email-aconole@bytheb.org>
Cc: David Miller <davem@davemloft.net>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
	Aaron Conole <aconole@bytheb.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f179.google.com ([209.85.220.179]:35885 "EHLO
	mail-qk0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754018AbbIZWvF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 26 Sep 2015 18:51:05 -0400
Received: by qkcf65 with SMTP id f65so55213814qkc.3
        for <netdev@vger.kernel.org>; Sat, 26 Sep 2015 15:51:04 -0700 (PDT)
In-Reply-To: <1443307843-16880-1-git-send-email-aconole@bytheb.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

As suggested by Eric Dumazet this change replaces the 
#define with a static inline function to enjoy 
complaints by the compiler when misusing the API.

Signed-off-by: Aaron Conole <aconole@bytheb.org>
---
 include/net/af_unix.h | 6 +++++-
 1 file changed, 5 insertions(+), 1 deletion(-)

diff --git a/include/net/af_unix.h b/include/net/af_unix.h
index 4a167b3..cb1b9bb 100644
--- a/include/net/af_unix.h
+++ b/include/net/af_unix.h
@@ -63,7 +63,11 @@ struct unix_sock {
 #define UNIX_GC_MAYBE_CYCLE	1
 	struct socket_wq	peer_wq;
 };
-#define unix_sk(__sk) ((struct unix_sock *)__sk)
+
+static inline struct unix_sock *unix_sk(struct sock *sk)
+{
+	return (struct unix_sock *)sk;
+}
 
 #define peer_wait peer_wq.wait
 
-- 
1.9.1
