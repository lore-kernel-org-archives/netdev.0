From: Li Wei <lw@cn.fujitsu.com>
Subject: [PATCH] ipv4: fix for ip_options_rcv_srr() daddr update.
Date: Wed, 09 Nov 2011 15:39:28 +0800
Message-ID: <4EBA2E30.8050102@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=GB2312
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:56452 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1752741Ab1KIHjF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 9 Nov 2011 02:39:05 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When opt->srr_is_hit is set skb_rtable(skb) has been updated for
'nexthop' and iph->daddr should always equals to skb_rtable->rt_dst
holds, We need update iph->daddr either.

Signed-off-by: Li Wei <lw@cn.fujitsu.com>
---
 net/ipv4/ip_options.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/net/ipv4/ip_options.c b/net/ipv4/ip_options.c
index ec93335..05d20cc 100644
--- a/net/ipv4/ip_options.c
+++ b/net/ipv4/ip_options.c
@@ -640,6 +640,7 @@ int ip_options_rcv_srr(struct sk_buff *skb)
 	}
 	if (srrptr <= srrspace) {
 		opt->srr_is_hit = 1;
+		iph->daddr = nexthop;
 		opt->is_changed = 1;
 	}
 	return 0;
-- 
1.7.3.2
