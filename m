From: Xin Long <lucien.xin@gmail.com>
Subject: [PATCH net] sctp: lack the check for ports in sctp_v6_cmp_addr
Date: Sun, 28 Feb 2016 10:03:51 +0800
Message-ID: <415cb449b7811635a13245e5ec99a5679516524a.1456625031.git.lucien.xin@gmail.com>
Cc: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>,
	Vlad Yasevich <vyasevich@gmail.com>, daniel@iogearbox.net,
	davem@davemloft.net
To: network dev <netdev@vger.kernel.org>, linux-sctp@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f193.google.com ([209.85.192.193]:36695 "EHLO
	mail-pf0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S2992640AbcB1CD4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 27 Feb 2016 21:03:56 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

As the member .cmp_addr of sctp_af_inet6, sctp_v6_cmp_addr should also check
the port of addresses, just like sctp_v4_cmp_addr, cause it's invoked by
sctp_cmp_addr_exact().

Now sctp_v6_cmp_addr just check the port when two addresses have different
family, and lack the port check for two ipv6 addresses. that will make
sctp_hash_cmp() cannot work well.

so fix it by adding ports comparison in sctp_v6_cmp_addr().

Signed-off-by: Xin Long <lucien.xin@gmail.com>
---
 net/sctp/ipv6.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/net/sctp/ipv6.c b/net/sctp/ipv6.c
index ec52912..ce46f1c 100644
--- a/net/sctp/ipv6.c
+++ b/net/sctp/ipv6.c
@@ -526,6 +526,8 @@ static int sctp_v6_cmp_addr(const union sctp_addr *addr1,
 		}
 		return 0;
 	}
+	if (addr1->v6.sin6_port != addr2->v6.sin6_port)
+		return 0;
 	if (!ipv6_addr_equal(&addr1->v6.sin6_addr, &addr2->v6.sin6_addr))
 		return 0;
 	/* If this is a linklocal address, compare the scope_id. */
-- 
2.1.0
