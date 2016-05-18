From: Tom Herbert <tom@herbertland.com>
Subject: [PATCH v7 net-next 16/16] ipv6: Don't reset inner headers in ip6_tnl_xmit
Date: Wed, 18 May 2016 09:06:24 -0700
Message-ID: <1463587584-2315623-17-git-send-email-tom@herbertland.com>
References: <1463587584-2315623-1-git-send-email-tom@herbertland.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <kernel-team@fb.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-00082601.pphosted.com ([67.231.153.30]:14407 "EHLO
	mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1753271AbcERQGy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 May 2016 12:06:54 -0400
Received: from pps.filterd (m0001303.ppops.net [127.0.0.1])
	by m0001303.ppops.net (8.16.0.11/8.16.0.11) with SMTP id u4IG436N016941
	for <netdev@vger.kernel.org>; Wed, 18 May 2016 09:06:53 -0700
Received: from mail.thefacebook.com ([199.201.64.23])
	by m0001303.ppops.net with ESMTP id 22wypbbc14-12
	(version=TLSv1 cipher=ECDHE-RSA-AES256-SHA bits=256 verify=NOT)
	for <netdev@vger.kernel.org>; Wed, 18 May 2016 09:06:53 -0700
Received: from devbig284.prn2.facebook.com (10.35.15.32)	by
 mx-out.facebook.com (10.102.107.99) with ESMTP	id
 86c65a1e1d1211e689100002c99293a0-3fbf2c50 for <netdev@vger.kernel.org>;	Wed,
 18 May 2016 09:06:48 -0700
In-Reply-To: <1463587584-2315623-1-git-send-email-tom@herbertland.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Since iptunnel_handle_offloads() is called in all paths we can
probably drop the block in ip6_tnl_xmit that was checking for
skb->encapsulation and resetting the inner headers.

Signed-off-by: Tom Herbert <tom@herbertland.com>
---
 net/ipv6/ip6_tunnel.c | 5 -----
 1 file changed, 5 deletions(-)

diff --git a/net/ipv6/ip6_tunnel.c b/net/ipv6/ip6_tunnel.c
index 823dad1..7b0481e 100644
--- a/net/ipv6/ip6_tunnel.c
+++ b/net/ipv6/ip6_tunnel.c
@@ -1120,11 +1120,6 @@ int ip6_tnl_xmit(struct sk_buff *skb, struct net_device *dev, __u8 dsfield,
 		ipv6_push_nfrag_opts(skb, &opt.ops, &proto, NULL);
 	}
 
-	if (likely(!skb->encapsulation)) {
-		skb_reset_inner_headers(skb);
-		skb->encapsulation = 1;
-	}
-
 	/* Calculate max headroom for all the headers and adjust
 	 * needed_headroom if necessary.
 	 */
-- 
2.8.0.rc2
