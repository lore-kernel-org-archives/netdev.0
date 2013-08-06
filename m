From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH] net: flow_dissector: add 802.1ad support
Date: Tue, 06 Aug 2013 04:35:06 -0700
Message-ID: <1375788906.4457.86.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f181.google.com ([209.85.192.181]:46796 "EHLO
	mail-pd0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755492Ab3HFLfK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Aug 2013 07:35:10 -0400
Received: by mail-pd0-f181.google.com with SMTP id g10so235909pdj.12
        for <netdev@vger.kernel.org>; Tue, 06 Aug 2013 04:35:08 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

Same behavior than 802.1q : finds the encapsulated protocol and
skip 32bit header.

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 net/core/flow_dissector.c |    1 +
 1 file changed, 1 insertion(+)

diff --git a/net/core/flow_dissector.c b/net/core/flow_dissector.c
index ade9ff1..159737c 100644
--- a/net/core/flow_dissector.c
+++ b/net/core/flow_dissector.c
@@ -65,6 +65,7 @@ ipv6:
 		nhoff += sizeof(struct ipv6hdr);
 		break;
 	}
+	case __constant_htons(ETH_P_8021AD):
 	case __constant_htons(ETH_P_8021Q): {
 		const struct vlan_hdr *vlan;
 		struct vlan_hdr _vlan;
