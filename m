From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next-2.6] net: ip_append_data() optim
Date: Tue, 24 Aug 2010 23:34:47 +0200
Message-ID: <1282685687.2467.175.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ew0-f46.google.com ([209.85.215.46]:36361 "EHLO
	mail-ew0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755533Ab0HXVe4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Aug 2010 17:34:56 -0400
Received: by ewy23 with SMTP id 23so3753233ewy.19
        for <netdev@vger.kernel.org>; Tue, 24 Aug 2010 14:34:55 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Compiler is not smart enough to avoid a conditional branch.

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 net/ipv4/ip_output.c |    7 +++----
 1 file changed, 3 insertions(+), 4 deletions(-)

diff --git a/net/ipv4/ip_output.c b/net/ipv4/ip_output.c
index 6d2753c..e427620 100644
--- a/net/ipv4/ip_output.c
+++ b/net/ipv4/ip_output.c
@@ -837,10 +837,9 @@ int ip_append_data(struct sock *sk,
 		inet->cork.length = 0;
 		sk->sk_sndmsg_page = NULL;
 		sk->sk_sndmsg_off = 0;
-		if ((exthdrlen = rt->dst.header_len) != 0) {
-			length += exthdrlen;
-			transhdrlen += exthdrlen;
-		}
+		exthdrlen = rt->dst.header_len;
+		length += exthdrlen;
+		transhdrlen += exthdrlen;
 	} else {
 		rt = (struct rtable *)inet->cork.dst;
 		if (inet->cork.flags & IPCORK_OPT)



