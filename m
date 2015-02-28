From: Tom Herbert <therbert@google.com>
Subject: [PATCH net-next 4/6] flow_dissector: Include VLAN ID in hash computation
Date: Fri, 27 Feb 2015 19:11:47 -0800
Message-ID: <1425093109-1077-5-git-send-email-therbert@google.com>
References: <1425093109-1077-1-git-send-email-therbert@google.com>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f170.google.com ([209.85.213.170]:42600 "EHLO
	mail-ig0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751542AbbB1DM5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Feb 2015 22:12:57 -0500
Received: by igkb16 with SMTP id b16so5346896igk.1
        for <netdev@vger.kernel.org>; Fri, 27 Feb 2015 19:12:56 -0800 (PST)
In-Reply-To: <1425093109-1077-1-git-send-email-therbert@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If VLAN is present include that in hash_extra in flow_keys when
dissecting. This will then be included in hash computation.

Signed-off-by: Tom Herbert <therbert@google.com>
---
 net/core/flow_dissector.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/net/core/flow_dissector.c b/net/core/flow_dissector.c
index 84bb794..b11eec1 100644
--- a/net/core/flow_dissector.c
+++ b/net/core/flow_dissector.c
@@ -155,6 +155,7 @@ ipv6:
 		if (!vlan)
 			return false;
 
+		flow->hash_extra ^= vlan->h_vlan_TCI;
 		proto = vlan->h_vlan_encapsulated_proto;
 		nhoff += sizeof(*vlan);
 		goto again;
-- 
2.2.0.rc0.207.ga3a616c
