From: Vladislav Yasevich <vyasevich@gmail.com>
Subject: [PATCH] ipv6: Partial checksum only UDP packets
Date: Tue, 10 Feb 2015 10:55:52 -0500
Message-ID: <1423583752-31932-1-git-send-email-vyasevic@redhat.com>
References: <20150210140704.GA3372@kria>
Cc: netdev@vger.kernel.org, Vladislav Yasevich <vyasevic@redhat.com>
To: sd@queasysnail.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qc0-f173.google.com ([209.85.216.173]:37292 "EHLO
	mail-qc0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751892AbbBJP4E (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Feb 2015 10:56:04 -0500
Received: by mail-qc0-f173.google.com with SMTP id w7so3500517qcr.4
        for <netdev@vger.kernel.org>; Tue, 10 Feb 2015 07:56:03 -0800 (PST)
In-Reply-To: <20150210140704.GA3372@kria>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

ip6_append_data is used by other protocols and some of them can't
be partially checksummed.  Only partially checksum UDP protocol.

Fixes: 32dce968dd987a (ipv6: Allow for partial checksums on non-ufo packets)
Reported-by: Sabrian Dubroca <sd@queasysnail.net>
Signed-off-by: Vladislav Yasevich <vyasevic@redhat.com>
---
Hi Sabrina

Can you try this patch.  Thanks.

 net/ipv6/ip6_output.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/ipv6/ip6_output.c b/net/ipv6/ip6_output.c
index d33df4c..8f2d558 100644
--- a/net/ipv6/ip6_output.c
+++ b/net/ipv6/ip6_output.c
@@ -1273,7 +1273,7 @@ emsgsize:
 	/* If this is the first and only packet and device
 	 * supports checksum offloading, let's use it.
 	 */
-	if (!skb &&
+	if (!skb && sk->protocol == IPPROTO_UDP &&
 	    length + fragheaderlen < mtu &&
 	    rt->dst.dev->features & NETIF_F_V6_CSUM &&
 	    !exthdrlen)
-- 
1.9.3
