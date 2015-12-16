From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net] inet: tcp: fix inetpeer_set_addr_v4()
Date: Tue, 15 Dec 2015 20:56:44 -0800
Message-ID: <1450241804.8474.71.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	David Ahern <dsa@cumulusnetworks.com>,
	Yuchung Cheng <ycheng@google.com>,
	Neal Cardwell <ncardwell@google.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f54.google.com ([209.85.220.54]:35430 "EHLO
	mail-pa0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751289AbbLPE4q (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Dec 2015 23:56:46 -0500
Received: by mail-pa0-f54.google.com with SMTP id hk6so17141027pad.2
        for <netdev@vger.kernel.org>; Tue, 15 Dec 2015 20:56:46 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

David Ahern added a vif field in the a4 part of inetpeer_addr struct.

This broke IPv4 TCP fast open client side and more generally tcp metrics
cache, because inetpeer_addr_cmp() is now comparing two u32 instead of
one.

inetpeer_set_addr_v4() needs to properly init vif field, otherwise
the comparison result depends on uninitialized data.

Fixes: 192132b9a034 ("net: Add support for VRFs to inetpeer cache")
Reported-by: Yuchung Cheng <ycheng@google.com>
Signed-off-by: Eric Dumazet <edumazet@google.com>
Cc: Neal Cardwell <ncardwell@google.com>
---
 include/net/inetpeer.h |    1 +
 1 file changed, 1 insertion(+)

diff --git a/include/net/inetpeer.h b/include/net/inetpeer.h
index 4a6009d4486b..235c7811a86a 100644
--- a/include/net/inetpeer.h
+++ b/include/net/inetpeer.h
@@ -78,6 +78,7 @@ void inet_initpeers(void) __init;
 static inline void inetpeer_set_addr_v4(struct inetpeer_addr *iaddr, __be32 ip)
 {
 	iaddr->a4.addr = ip;
+	iaddr->a4.vif = 0;
 	iaddr->family = AF_INET;
 }
 
