From: Aaron Conole <aconole@bytheb.org>
Subject: [PATCH v3 1/2] [net] af_unix: Convert the unix_sk macro to an inline function for type safety
Date: Mon, 21 Sep 2015 20:27:01 -0400
Message-ID: <1442881622-11316-2-git-send-email-aconole@bytheb.org>
References: <1442881622-11316-1-git-send-email-aconole@bytheb.org>
Cc: Aaron Conole <aconole@bytheb.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qg0-f44.google.com ([209.85.192.44]:35547 "EHLO
	mail-qg0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756872AbbIVA1N (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Sep 2015 20:27:13 -0400
Received: by qgt47 with SMTP id 47so104426354qgt.2
        for <netdev@vger.kernel.org>; Mon, 21 Sep 2015 17:27:12 -0700 (PDT)
In-Reply-To: <1442881622-11316-1-git-send-email-aconole@bytheb.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

As suggested by Eric Dumazet in
http://marc.info/?l=linux-netdev&m=144276759421433&w=2

This change replaces the #define with a static inline function to
enjoy complaints by the compiler when misusing the API.

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
