From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 04/14] ipv6: added net argument to
 IP6_INC_STATS_BH
Date: Wed, 08 Oct 2008 11:13:09 -0700 (PDT)
Message-ID: <20081008.111309.227060133.davem@davemloft.net>
References: <1223466685.7184.13.camel@iris.sw.ru>
	<1223466722-8169-4-git-send-email-den@openvz.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, dlezcano@fr.ibm.com,
	benjamin.thery@bull.net, xemul@openvz.org, yoshfuji@linux-ipv6.org
To: den@openvz.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:54231
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753982AbYJHSNd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Oct 2008 14:13:33 -0400
In-Reply-To: <1223466722-8169-4-git-send-email-den@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Denis V. Lunev" <den@openvz.org>
Date: Wed,  8 Oct 2008 15:51:52 +0400

> Signed-off-by: Denis V. Lunev <den@openvz.org>

Please type "make allmodconfig" before all test builds.
Or at least use grep when changing interface signatures.

You missed net/ipv6/ip6mr.c in these changes.

I added the following change to your commit to fix the
build:

diff --git a/net/ipv6/ip6mr.c b/net/ipv6/ip6mr.c
index 095bc45..182f8a1 100644
--- a/net/ipv6/ip6mr.c
+++ b/net/ipv6/ip6mr.c
@@ -1383,7 +1383,8 @@ int ip6mr_ioctl(struct sock *sk, int cmd, void __user *arg)
 
 static inline int ip6mr_forward2_finish(struct sk_buff *skb)
 {
-	IP6_INC_STATS_BH(ip6_dst_idev(skb->dst), IPSTATS_MIB_OUTFORWDATAGRAMS);
+	IP6_INC_STATS_BH(dev_net(skb->dst->dev), ip6_dst_idev(skb->dst),
+			 IPSTATS_MIB_OUTFORWDATAGRAMS);
 	return dst_output(skb);
 }
 
