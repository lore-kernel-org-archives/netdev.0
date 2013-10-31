From: Yuchung Cheng <ycheng@google.com>
Subject: [PATCH net-next] tcp: enable sockets to use MSG_FASTOPEN by default
Date: Thu, 31 Oct 2013 09:19:32 -0700
Message-ID: <1383236372-1317-1-git-send-email-ycheng@google.com>
Cc: netdev@vger.kernel.org, ncardwell@google.com,
	sivasankar@cs.ucsd.edu, Yuchung Cheng <ycheng@google.com>
To: davem@davemloft.net, edumazet@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f202.google.com ([209.85.214.202]:46230 "EHLO
	mail-ob0-f202.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752122Ab3JaQUR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 31 Oct 2013 12:20:17 -0400
Received: by mail-ob0-f202.google.com with SMTP id wn1so640601obc.5
        for <netdev@vger.kernel.org>; Thu, 31 Oct 2013 09:20:16 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Applications have started to use Fast Open (e.g., Chrome browser has
such an optional flag) and the feature has gone through several
generations of kernels since 3.7 with many real network tests. It's
time to enable this flag by default for applications to test more
conveniently and extensively.

Signed-off-by: Yuchung Cheng <ycheng@google.com>
Signed-off-by: Neal Cardwell <ncardwell@google.com>
---
 Documentation/networking/ip-sysctl.txt | 4 ++--
 net/ipv4/tcp_fastopen.c                | 2 +-
 2 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/Documentation/networking/ip-sysctl.txt b/Documentation/networking/ip-sysctl.txt
index a46d785..6c00983 100644
--- a/Documentation/networking/ip-sysctl.txt
+++ b/Documentation/networking/ip-sysctl.txt
@@ -451,7 +451,7 @@ tcp_fastopen - INTEGER
 	connect() to perform a TCP handshake automatically.
 
 	The values (bitmap) are
-	1: Enables sending data in the opening SYN on the client.
+	1: Enables sending data in the opening SYN on the client w/ MSG_FASTOPEN.
 	2: Enables TCP Fast Open on the server side, i.e., allowing data in
 	   a SYN packet to be accepted and passed to the application before
 	   3-way hand shake finishes.
@@ -464,7 +464,7 @@ tcp_fastopen - INTEGER
 	   different ways of setting max_qlen without the TCP_FASTOPEN socket
 	   option.
 
-	Default: 0
+	Default: 1
 
 	Note that the client & server side Fast Open flags (1 and 2
 	respectively) must be also enabled before the rest of flags can take
diff --git a/net/ipv4/tcp_fastopen.c b/net/ipv4/tcp_fastopen.c
index 766032b..f195d93 100644
--- a/net/ipv4/tcp_fastopen.c
+++ b/net/ipv4/tcp_fastopen.c
@@ -8,7 +8,7 @@
 #include <net/inetpeer.h>
 #include <net/tcp.h>
 
-int sysctl_tcp_fastopen __read_mostly;
+int sysctl_tcp_fastopen __read_mostly = TFO_CLIENT_ENABLE;
 
 struct tcp_fastopen_context __rcu *tcp_fastopen_ctx;
 
-- 
1.8.4.1
