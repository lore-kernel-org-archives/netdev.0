From: Roel Kluin <roel.kluin@gmail.com>
Subject: [PATCH] net: Cleanup redundant tests on unsigned
Date: Fri, 23 Oct 2009 17:59:21 +0200
Message-ID: <4AE1D2D9.5000906@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Andrew Morton <akpm@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ew0-f208.google.com ([209.85.219.208]:45618 "EHLO
	mail-ew0-f208.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752302AbZJWPtB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 Oct 2009 11:49:01 -0400
Received: by ewy4 with SMTP id 4so1751623ewy.37
        for <netdev@vger.kernel.org>; Fri, 23 Oct 2009 08:49:05 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

optlen is unsigned so the `< 0' test is never true.

Signed-off-by: Roel Kluin <roel.kluin@gmail.com>
---
 net/can/raw.c          |    2 --
 net/compat.c           |    3 ---
 net/ipv4/ip_sockglue.c |    2 +-
 3 files changed, 1 insertions(+), 6 deletions(-)

Or should the tests in net/can/raw.c or net/compat.c
be replaced by something else?

diff --git a/net/can/raw.c b/net/can/raw.c
index b5e8979..9e18c2a 100644
--- a/net/can/raw.c
+++ b/net/can/raw.c
@@ -424,8 +424,6 @@ static int raw_setsockopt(struct socket *sock, int level, int optname,
 
 	if (level != SOL_CAN_RAW)
 		return -EINVAL;
-	if (optlen < 0)
-		return -EINVAL;
 
 	switch (optname) {
 
diff --git a/net/compat.c b/net/compat.c
index a407c3a..e373995 100644
--- a/net/compat.c
+++ b/net/compat.c
@@ -390,9 +390,6 @@ asmlinkage long compat_sys_setsockopt(int fd, int level, int optname,
 	int err;
 	struct socket *sock;
 
-	if (optlen < 0)
-		return -EINVAL;
-
 	if ((sock = sockfd_lookup(fd, &err))!=NULL)
 	{
 		err = security_socket_setsockopt(sock,level,optname);
diff --git a/net/ipv4/ip_sockglue.c b/net/ipv4/ip_sockglue.c
index e982b5c..15dbf30 100644
--- a/net/ipv4/ip_sockglue.c
+++ b/net/ipv4/ip_sockglue.c
@@ -480,7 +480,7 @@ static int do_ip_setsockopt(struct sock *sk, int level,
 	case IP_OPTIONS:
 	{
 		struct ip_options *opt = NULL;
-		if (optlen > 40 || optlen < 0)
+		if (optlen > 40)
 			goto e_inval;
 		err = ip_options_get_from_user(sock_net(sk), &opt,
 					       optval, optlen);
