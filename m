From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next] flow_dissector: do not break if ports are not needed in flowlabel
Date: Fri, 22 May 2015 11:05:58 +0200
Message-ID: <1432285558-19470-1-git-send-email-jiri@resnulli.us>
Cc: tom@herbertland.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f170.google.com ([209.85.212.170]:36277 "EHLO
	mail-wi0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757060AbbEVJGD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 May 2015 05:06:03 -0400
Received: by wizk4 with SMTP id k4so40608908wiz.1
        for <netdev@vger.kernel.org>; Fri, 22 May 2015 02:06:01 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This restored previous behaviour. If caller does not want ports to be
filled, we should not break.

Fixes: 06635a35d13d ("flow_dissect: use programable dissector in skb_flow_dissect and friends")
Signed-off-by: Jiri Pirko <jiri@resnulli.us>
---
 net/core/flow_dissector.c | 14 +++++++-------
 1 file changed, 7 insertions(+), 7 deletions(-)

diff --git a/net/core/flow_dissector.c b/net/core/flow_dissector.c
index 703d059..1f2d893 100644
--- a/net/core/flow_dissector.c
+++ b/net/core/flow_dissector.c
@@ -221,13 +221,13 @@ flow_label:
 			key_basic->ip_proto = ip_proto;
 			key_basic->thoff = (u16)nhoff;
 
-			if (!skb_flow_dissector_uses_key(flow_dissector,
-							 FLOW_DISSECTOR_KEY_PORTS))
-				break;
-			key_ports = skb_flow_dissector_target(flow_dissector,
-							      FLOW_DISSECTOR_KEY_PORTS,
-							      target_container);
-			key_ports->ports = flow_label;
+			if (skb_flow_dissector_uses_key(flow_dissector,
+							FLOW_DISSECTOR_KEY_PORTS)) {
+				key_ports = skb_flow_dissector_target(flow_dissector,
+								      FLOW_DISSECTOR_KEY_PORTS,
+								      target_container);
+				key_ports->ports = flow_label;
+			}
 
 			return true;
 		}
-- 
1.9.3
