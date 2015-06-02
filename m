From: Denis Kirjanov <kda@linux-powerpc.org>
Subject: [net-next v2] ipv4: inet_bind: check the addr_len first
Date: Tue,  2 Jun 2015 15:21:04 +0300
Message-ID: <1433247664-7151-1-git-send-email-kda@linux-powerpc.org>
Cc: Denis Kirjanov <kda@linux-powerpc.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f54.google.com ([209.85.215.54]:32801 "EHLO
	mail-la0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753437AbbFBMWc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Jun 2015 08:22:32 -0400
Received: by labpy14 with SMTP id py14so112190271lab.0
        for <netdev@vger.kernel.org>; Tue, 02 Jun 2015 05:22:31 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Perform the address length check first, before calling
the proto specific bind() function

Signed-off-by: Denis Kirjanov <kda@linux-powerpc.org>

v2: add the proper tag tp the subject
---
 net/ipv4/af_inet.c |    7 ++++---
 1 file changed, 4 insertions(+), 3 deletions(-)

diff --git a/net/ipv4/af_inet.c b/net/ipv4/af_inet.c
index 6ad0f7a..333e2fa 100644
--- a/net/ipv4/af_inet.c
+++ b/net/ipv4/af_inet.c
@@ -426,14 +426,15 @@ int inet_bind(struct socket *sock, struct sockaddr *uaddr, int addr_len)
 	int chk_addr_ret;
 	int err;
 
+	err = -EINVAL;
+	if (addr_len < sizeof(struct sockaddr_in))
+		goto out;
+
 	/* If the socket has its own bind function then use it. (RAW) */
 	if (sk->sk_prot->bind) {
 		err = sk->sk_prot->bind(sk, uaddr, addr_len);
 		goto out;
 	}
-	err = -EINVAL;
-	if (addr_len < sizeof(struct sockaddr_in))
-		goto out;
 
 	if (addr->sin_family != AF_INET) {
 		/* Compatibility games : accept AF_UNSPEC (mapped to AF_INET)
-- 
1.7.10.4
