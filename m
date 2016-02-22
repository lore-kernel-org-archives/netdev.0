From: Craig Gallek <kraigatgoog@gmail.com>
Subject: [PATCH net-next] soreuseport: fix merge conflict in tcp bind
Date: Mon, 22 Feb 2016 10:45:29 -0500
Message-ID: <1456155929-2708-1-git-send-email-kraigatgoog@gmail.com>
Cc: eric.dumazet@gmail.com
To: netdev@vger.kernel.org, David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qg0-f49.google.com ([209.85.192.49]:33415 "EHLO
	mail-qg0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754116AbcBVPpc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Feb 2016 10:45:32 -0500
Received: by mail-qg0-f49.google.com with SMTP id b35so113521754qge.0
        for <netdev@vger.kernel.org>; Mon, 22 Feb 2016 07:45:32 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Craig Gallek <kraig@google.com>

One of the validation checks for the new array-based TCP SO_REUSEPORT
validation was unintentionally dropped in ea8add2b1903.  This adds it back.

Lack of this check allows the user to allocate multiple sock_reuseport
structures (leaking all but the first).

Fixes: ea8add2b1903 ("tcp/dccp: better use of ephemeral ports in bind()")
Signed-off-by: Craig Gallek <kraig@google.com>
---
 net/ipv4/inet_connection_sock.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/net/ipv4/inet_connection_sock.c b/net/ipv4/inet_connection_sock.c
index 3d28c6d5c3c3..fb0349acbd45 100644
--- a/net/ipv4/inet_connection_sock.c
+++ b/net/ipv4/inet_connection_sock.c
@@ -202,6 +202,7 @@ tb_found:
 
 		if (((tb->fastreuse > 0 && reuse) ||
 		     (tb->fastreuseport > 0 &&
+		      !rcu_access_pointer(sk->sk_reuseport_cb) &&
 		      sk->sk_reuseport && uid_eq(tb->fastuid, uid))) &&
 		    smallest_size == -1)
 			goto success;
-- 
2.7.0.rc3.207.g0ac5344
