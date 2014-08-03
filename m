From: Dmitry Popov <ixaphire@qrator.net>
Subject: [PATCH] tcp: md5: remove unneeded check in tcp_v4_parse_md5_keys
Date: Sun, 3 Aug 2014 22:45:19 +0400
Message-ID: <20140803224519.49a40242da5c1cbe61f97753@qrator.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
To: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f178.google.com ([209.85.217.178]:51793 "EHLO
	mail-lb0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751536AbaHCSp1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 3 Aug 2014 14:45:27 -0400
Received: by mail-lb0-f178.google.com with SMTP id c11so4710656lbj.9
        for <netdev@vger.kernel.org>; Sun, 03 Aug 2014 11:45:25 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

tcpm_key is an array inside struct tcp_md5sig, there is no need to check it
against NULL.

Signed-off-by: Dmitry Popov <ixaphire@qrator.net>
---
 net/ipv4/tcp_ipv4.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)
diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index 77cccda..8ea4eff 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -1064,7 +1064,7 @@ static int tcp_v4_parse_md5_keys(struct sock *sk, char __user *optval,
 	if (sin->sin_family != AF_INET)
 		return -EINVAL;
 
-	if (!cmd.tcpm_key || !cmd.tcpm_keylen)
+	if (!cmd.tcpm_keylen)
 		return tcp_md5_do_del(sk, (union tcp_md5_addr *)&sin->sin_addr.s_addr,
 				      AF_INET);
 
