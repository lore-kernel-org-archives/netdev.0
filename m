From: "Adam Langley" <agl@imperialviolet.org>
Subject: [PATCH] tcp: MD5: Fix IPv6 signatures
Date: Thu, 31 Jul 2008 21:31:31 -0700
Message-ID: <396556a20805301217k293e5718h6bbf02bfe069051@europa>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from wf-out-1314.google.com ([209.85.200.175]:49596 "EHLO
	wf-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751239AbYHAEdu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 Aug 2008 00:33:50 -0400
Received: by wf-out-1314.google.com with SMTP id 27so1185245wfd.4
        for <netdev@vger.kernel.org>; Thu, 31 Jul 2008 21:33:50 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Reported by Stefanos Harhalakis; although 2.6.27-rc1 talks to itself using IPv6
TCP MD5 packets just fine, Stefanos noted that tcpdump claimed that the
signatures were invalid.

I broke this in 49a72dfb8814c2d65bd9f8c9c6daf6395a1ec58d ("tcp: Fix MD5
signatures for non-linear skbs"), it was just a typo.

Note that tcpdump will still sometimes claim that the signatures are incorrect.
A patch to tcpdump has been submitted for this[1].

[1] http://tinyurl.com/6a4fl2

Signed-off-by: Adam Langley <agl@imperialviolet.org>
---

 net/ipv6/tcp_ipv6.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/ipv6/tcp_ipv6.c b/net/ipv6/tcp_ipv6.c
index 1bcdcbc..78185a4 100644
--- a/net/ipv6/tcp_ipv6.c
+++ b/net/ipv6/tcp_ipv6.c
@@ -748,7 +748,7 @@ static int tcp_v6_md5_hash_pseudoheader(struct tcp_md5sig_pool *hp,
 	ipv6_addr_copy(&bp->saddr, saddr);
 	ipv6_addr_copy(&bp->daddr, daddr);
 	bp->protocol = cpu_to_be32(IPPROTO_TCP);
-	bp->len = cpu_to_be16(nbytes);
+	bp->len = cpu_to_be32(nbytes);
 
 	sg_init_one(&sg, bp, sizeof(*bp));
 	return crypto_hash_update(&hp->md5_desc, &sg, sizeof(*bp));
