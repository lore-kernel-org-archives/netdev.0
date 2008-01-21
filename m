From: Wang Chen <wangchen@cn.fujitsu.com>
Subject: [PATCH 1/2] IPV6: ICMP6_MIB_OUTMSGS increment duplicated
Date: Mon, 21 Jan 2008 17:46:32 +0800
Message-ID: <479469F8.4010203@cn.fujitsu.com>
References: <478DD57B.6020503@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: David L Stevens <dlstevens@us.ibm.com>, netdev@vger.kernel.org,
	Herbert Xu <herbert@gondor.apana.org.au>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:61564 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1758281AbYAUJsF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 21 Jan 2008 04:48:05 -0500
In-Reply-To: <478DD57B.6020503@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

[IPV6]: ICMP6_MIB_OUTMSGS increment duplicated

icmpv6_send() calls ip6_push_pending_frames() indirectly.
Both ip6_push_pending_frames() and icmpv6_send() increment
counter ICMP6_MIB_OUTMSGS.

This patch remove the increment from icmpv6_send.

Signed-off-by: Wang Chen <wangchen@cn.fujitsu.com>

--- linux-2.6.24.rc8.org/net/ipv6/icmp.c	2008-01-16 17:45:03.000000000 +0800
+++ linux-2.6.24.rc8/net/ipv6/icmp.c	2008-01-21 15:56:06.000000000 +0800
@@ -458,8 +458,6 @@ void icmpv6_send(struct sk_buff *skb, in
 	}
 	err = icmpv6_push_pending_frames(sk, &fl, &tmp_hdr, len + sizeof(struct icmp6hdr));
 
-	ICMP6_INC_STATS_BH(idev, ICMP6_MIB_OUTMSGS);
-
 out_put:
 	if (likely(idev != NULL))
 		in6_dev_put(idev);


