From: Julian Anastasov <ja@ssi.bg>
Subject: Re: [PATCH 4/10] ipvs: Use IP_VS_RT_MODE_* instead of magic
 constants.
Date: Wed, 11 May 2011 01:26:09 +0300 (EEST)
Message-ID: <alpine.LFD.2.00.1105110123001.4532@ja.ssi.bg>
References: <20110509.223118.260083861.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ja.ssi.bg ([178.16.129.10]:42578 "EHLO ja.ssi.bg"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751041Ab1EJWYk (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 10 May 2011 18:24:40 -0400
In-Reply-To: <20110509.223118.260083861.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


	Fix more IP_VS_RT_MODE_* constants

Signed-off-by: Julian Anastasov <ja@ssi.bg>
---

	Following patch can be used after patch 4, eg. as
number 6 because patches 4 and 5 are ok and we are going to replace
patches 6 and 7.

diff -urp net-next-2.6-7ef73bc/linux/net/netfilter/ipvs/ip_vs_xmit.c linux/net/netfilter/ipvs/ip_vs_xmit.c
--- net-next-2.6-7ef73bc/linux/net/netfilter/ipvs/ip_vs_xmit.c	2011-05-10 23:51:34.831272176 +0300
+++ linux/net/netfilter/ipvs/ip_vs_xmit.c	2011-05-10 23:51:28.900271527 +0300
@@ -230,8 +230,6 @@ out_err:
 
 /*
  * Get route to destination or remote server
- * rt_mode: flags, &1=Allow local dest, &2=Allow non-local dest,
- *	    &4=Allow redirect from remote daddr to local
  */
 static struct rt6_info *
 __ip_vs_get_out_rt_v6(struct sk_buff *skb, struct ip_vs_dest *dest,
@@ -275,13 +273,14 @@ __ip_vs_get_out_rt_v6(struct sk_buff *sk
 	}
 
 	local = __ip_vs_is_local_route6(rt);
-	if (!((local ? 1 : 2) & rt_mode)) {
+	if (!((local ? IP_VS_RT_MODE_LOCAL : IP_VS_RT_MODE_NON_LOCAL) &
+	      rt_mode)) {
 		IP_VS_DBG_RL("Stopping traffic to %s address, dest: %pI6\n",
 			     local ? "local":"non-local", daddr);
 		dst_release(&rt->dst);
 		return NULL;
 	}
-	if (local && !(rt_mode & 4) &&
+	if (local && !(rt_mode & IP_VS_RT_MODE_RDR) &&
 	    !((ort = (struct rt6_info *) skb_dst(skb)) &&
 	      __ip_vs_is_local_route6(ort))) {
 		IP_VS_DBG_RL("Redirect from non-local address %pI6 to local "
