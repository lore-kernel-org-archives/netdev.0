From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH] net: flow_dissector: fix thoff for IPPROTO_AH
Date: Thu, 26 Sep 2013 08:44:06 -0700
Message-ID: <1380210246.3165.184.camel@edumazet-glaptop>
References: <1380204582-27144-1-git-send-email-nikolay@redhat.com>
	 <1380204582-27144-2-git-send-email-nikolay@redhat.com>
	 <1380209227.3165.176.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Daniel Borkmann <dborkman@redhat.com>, netdev@vger.kernel.org,
	davem@davemloft.net, andy@greyhouse.net, fubar@us.ibm.com,
	vfalico@redhat.com
To: Nikolay Aleksandrov <nikolay@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f52.google.com ([209.85.160.52]:55274 "EHLO
	mail-pb0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751093Ab3IZPoJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Sep 2013 11:44:09 -0400
Received: by mail-pb0-f52.google.com with SMTP id wz12so1281634pbc.39
        for <netdev@vger.kernel.org>; Thu, 26 Sep 2013 08:44:08 -0700 (PDT)
In-Reply-To: <1380209227.3165.176.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

In commit 8ed781668dd49 ("flow_keys: include thoff into flow_keys for
later usage"), we missed that existing code was using nhoff as a
temporary variable that could not always contain transport header
offset.

This is not a problem for TCP/UDP because port offset (@poff)
is 0 for these protocols.

Signed-off-by: Eric Dumazet <edumazet@google.com>
Cc: Daniel Borkmann <dborkman@redhat.com>
Cc: Nikolay Aleksandrov <nikolay@redhat.com>
---
 net/core/flow_dissector.c |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/core/flow_dissector.c b/net/core/flow_dissector.c
index 1929af8..8d7d0dd 100644
--- a/net/core/flow_dissector.c
+++ b/net/core/flow_dissector.c
@@ -154,8 +154,8 @@ ipv6:
 	if (poff >= 0) {
 		__be32 *ports, _ports;
 
-		nhoff += poff;
-		ports = skb_header_pointer(skb, nhoff, sizeof(_ports), &_ports);
+		ports = skb_header_pointer(skb, nhoff + poff,
+					   sizeof(_ports), &_ports);
 		if (ports)
 			flow->ports = *ports;
 	}
