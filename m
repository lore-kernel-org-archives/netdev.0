From: Vladislav Yasevich <vyasevich@gmail.com>
Subject: [PATCH v2 net-next] ipv6: Partial checksum only UDP packets
Date: Tue, 10 Feb 2015 11:37:29 -0500
Message-ID: <1423586249-5950-1-git-send-email-vyasevic@redhat.com>
Cc: sd@queasysnail.net, Vladislav Yasevich <vyasevic@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qc0-f170.google.com ([209.85.216.170]:43456 "EHLO
	mail-qc0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751154AbbBJQhi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Feb 2015 11:37:38 -0500
Received: by mail-qc0-f170.google.com with SMTP id i8so15417250qcq.1
        for <netdev@vger.kernel.org>; Tue, 10 Feb 2015 08:37:37 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

ip6_append_data is used by other protocols and some of them can't
be partially checksummed.  Only partially checksum UDP protocol.

Fixes: 32dce968dd987a (ipv6: Allow for partial checksums on non-ufo packets)
Reported-by: Sabrina Dubroca <sd@queasysnail.net>
Tested-by: Sabrina Dubroca <sd@queasysnail.net>
Signed-off-by: Vladislav Yasevich <vyasevic@redhat.com>
---
v2:  added tested-by tag and fixed compile issue with prior patch.

 net/ipv6/ip6_output.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/ipv6/ip6_output.c b/net/ipv6/ip6_output.c
index d33df4c..7deebf1 100644
--- a/net/ipv6/ip6_output.c
+++ b/net/ipv6/ip6_output.c
@@ -1273,7 +1273,7 @@ emsgsize:
 	/* If this is the first and only packet and device
 	 * supports checksum offloading, let's use it.
 	 */
-	if (!skb &&
+	if (!skb && sk->sk_protocol == IPPROTO_UDP &&
 	    length + fragheaderlen < mtu &&
 	    rt->dst.dev->features & NETIF_F_V6_CSUM &&
 	    !exthdrlen)
-- 
1.9.3
