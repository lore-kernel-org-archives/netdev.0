From: Adrian Bunk <bunk@kernel.org>
Subject: [2.6 patch] __inet6_csk_dst_store(): fix check-after-use
Date: Sun, 14 Oct 2007 19:52:12 +0200
Message-ID: <20071014175212.GP4211@stusta.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Noriaki TAKAMIYA <takamiya@po.ntts.co.jp>,
	Masahide NAKAMURA <nakam@linux-ipv6.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from emailhub.stusta.mhn.de ([141.84.69.5]:35265 "EHLO
	mailhub.stusta.mhn.de" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1758492AbXJNRvm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 14 Oct 2007 13:51:42 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The Coverity checker spotted that we have already oops'ed if "dst"
was NULL.

Since "dst" being NULL doesn't seem to be possible at this point this 
patch removes the NULL check.

Signed-off-by: Adrian Bunk <bunk@stusta.de>

---
eeb6009cf3ef5f6993ced359330d877680617a70 
diff --git a/net/ipv6/inet6_connection_sock.c b/net/ipv6/inet6_connection_sock.c
index 25b9317..78de42a 100644
--- a/net/ipv6/inet6_connection_sock.c
+++ b/net/ipv6/inet6_connection_sock.c
@@ -146,7 +146,7 @@ void __inet6_csk_dst_store(struct sock *sk, struct dst_entry *dst,
 	__ip6_dst_store(sk, dst, daddr, saddr);
 
 #ifdef CONFIG_XFRM
-	if (dst) {
+	{
 		struct rt6_info *rt = (struct rt6_info  *)dst;
 		rt->rt6i_flow_cache_genid = atomic_read(&flow_cache_genid);
 	}
