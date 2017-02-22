From: Roi Dayan <roid@mellanox.com>
Subject: [PATCH iproute2] tc: flower: Fix parsing ip address
Date: Wed, 22 Feb 2017 16:05:01 +0200
Message-ID: <1487772301-22303-1-git-send-email-roid@mellanox.com>
Cc: netdev@vger.kernel.org, Paul Blakey <paulb@mellanox.com>,
        Or Gerlitz <ogerlitz@mellanox.com>,
        Hadar Hen Zion <hadarh@mellanox.com>,
        Shahar Klein <shahark@mellanox.com>,
        Mark Bloch <markb@mellanox.com>,
        Simon Horman <simon.horman@netronome.com>,
        Jiri Pirko <jiri@mellanox.com>, Roi Dayan <roid@mellanox.com>
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:46079 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S932613AbdBVOGs (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 22 Feb 2017 09:06:48 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fix order of arguments when passed to __flower_parse_ip_addr.

Fixes: ("f888f4e20534 tc: flower: Support matching ARP")
Signed-off-by: Roi Dayan <roid@mellanox.com>
Reviewed-by: Paul Blakey <paulb@mellanox.com>
---
 tc/f_flower.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/tc/f_flower.c b/tc/f_flower.c
index 6bd03f2..5aac4a0 100644
--- a/tc/f_flower.c
+++ b/tc/f_flower.c
@@ -289,8 +289,8 @@ static int flower_parse_ip_addr(char *str, __be16 eth_type,
 		return -1;
 	}
 
-	return __flower_parse_ip_addr(str, family, addr4_type, addr6_type,
-				      mask4_type, mask6_type, n);
+	return __flower_parse_ip_addr(str, family, addr4_type, mask4_type,
+				      addr6_type, mask6_type, n);
 }
 
 static bool flower_eth_type_arp(__be16 eth_type)
-- 
2.7.4
