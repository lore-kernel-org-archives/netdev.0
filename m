From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
	<yoshfuji@linux-ipv6.org>
Subject: Re: [PATCH] [net-2.6.26] [IPV6] Add stats in multicast routing
 module method ip6_mr_forward().
Date: Mon, 14 Apr 2008 15:59:16 +0900 (JST)
Message-ID: <20080414.155916.22280629.yoshfuji@linux-ipv6.org>
References: <eb3ff54b0804101121lf741824xb875cf49a2629cc6@mail.gmail.com>
	<20080413.231806.221764599.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ramirose@gmail.com, netdev@vger.kernel.org, yoshfuji@linux-ipv6.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from yue.linux-ipv6.org ([203.178.140.15]:33493 "EHLO
	yue.st-paulia.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757434AbYDNG5c (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Apr 2008 02:57:32 -0400
In-Reply-To: <20080413.231806.221764599.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In article <20080413.231806.221764599.davem@davemloft.net> (at Sun, 13 Apr 2008 23:18:06 -0700 (PDT)), David Miller <davem@davemloft.net> says:

> From: "Rami Rosen" <ramirose@gmail.com>
> Date: Thu, 10 Apr 2008 21:21:12 +0300
> 
> >   This patches adds a call to increment IPSTATS_MIB_OUTFORWDATAGRAMS
> >    when forwarding the packet in ip6_mr_forward() in the IPv6
> > multicast routing module (net/ipv6/ip6mr.c).
> > 	
> > Signed-off-by: Rami Rosen <ramirose@gmail.com>
> 
> This looks OK to me, but I'll let Yoshifuji pick it up.

I'm okay with it.
Here it is.

----
>From e70bc6976e796815e176912a92f72719f7276de1 Mon Sep 17 00:00:00 2001
From: Rami Rosen <ramirose@gmail.com>
Date: Thu, 10 Apr 2008 21:21:12 +0300
Subject: [PATCH] [IPV6] MROUTE: Add stats in multicast routing module method ip6_mr_forward().

This patches adds a call to increment IPSTATS_MIB_OUTFORWDATAGRAMS
when forwarding the packet in ip6_mr_forward() in the IPv6
multicast routing module (net/ipv6/ip6mr.c).

Signed-off-by: Rami Rosen <ramirose@gmail.com>
Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
---
 net/ipv6/ip6mr.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/ipv6/ip6mr.c b/net/ipv6/ip6mr.c
index 94ede69..0971f4b 100644
--- a/net/ipv6/ip6mr.c
+++ b/net/ipv6/ip6mr.c
@@ -1359,7 +1359,7 @@ int ip6mr_ioctl(struct sock *sk, int cmd, void __user *arg)
 
 static inline int ip6mr_forward2_finish(struct sk_buff *skb)
 {
-	/* XXX stats */
+	IP6_INC_STATS_BH(ip6_dst_idev(skb->dst), IPSTATS_MIB_OUTFORWDATAGRAMS);
 	return dst_output(skb);
 }
 
-- 
1.4.4.4

-- 
YOSHIFUJI Hideaki @ USAGI Project  <yoshfuji@linux-ipv6.org>
GPG-FP  : 9022 65EB 1ECF 3AD1 0BDF  80D8 4807 F894 E062 0EEA
