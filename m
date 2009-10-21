From: Joyce Yu <Joyce.Yu@Sun.COM>
Subject: Re: [PATCH] [NIU] VLAN does not work with niu driver
Date: Wed, 21 Oct 2009 16:28:45 -0700
Message-ID: <4ADF992D.40507@Sun.COM>
References: <4ADF4CBD.90104@Sun.COM>
 <20091021.160923.26786943.davem@davemloft.net>
Reply-To: Joyce.Yu@Sun.COM
Mime-Version: 1.0
Content-Type: text/plain; CHARSET=US-ASCII; format=flowed
Content-Transfer-Encoding: 7BIT
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from brmea-mail-2.Sun.COM ([192.18.98.43]:63129 "EHLO
	brmea-mail-2.sun.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752597AbZJUX2m (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Oct 2009 19:28:42 -0400
Received: from fe-amer-09.sun.com ([192.18.109.79])
	by brmea-mail-2.sun.com (8.13.6+Sun/8.12.9) with ESMTP id n9LNSkxR012923
	for <netdev@vger.kernel.org>; Wed, 21 Oct 2009 23:28:46 GMT
Received: from conversion-daemon.mail-amer.sun.com by mail-amer.sun.com
 (Sun Java(tm) System Messaging Server 7u2-7.04 64bit (built Jul  2 2009))
 id <0KRW002000WOJZ00@mail-amer.sun.com> for netdev@vger.kernel.org; Wed,
 21 Oct 2009 17:28:46 -0600 (MDT)
In-reply-to: <20091021.160923.26786943.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


It was in the patch. Was an empty line needed after the body of the 
explanation? I will send out one with an empty line between body of the 
explanation and signed-off-by tag.

Thanks,
Joyce


 From f301748d3156437d65305f14288c7d5711861980 Mon Sep 17 00:00:00 2001
From: Joyce Yu <joyce.yu@sun.com>
Date: Wed, 21 Oct 2009 05:35:46 -0700
Subject: [PATCH] VLAN_ETH_HLEN should be used to make sure that the 
whole MAC header was copied to the head buffer in the Vlan packets case
Signed-off-by: Joyce Yu <joyce.yu@sun.com>  <=============== tag

---
  drivers/net/niu.c |    2 +-
  1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/niu.c b/drivers/net/niu.c
index f9364d0..d6c7ac6 100644
--- a/drivers/net/niu.c
+++ b/drivers/net/niu.c
@@ -3545,7 +3545,7 @@ static int niu_process_rx_pkt(struct napi_struct 
*napi, struct niu *np,
  	rp->rcr_index = index;

  	skb_reserve(skb, NET_IP_ALIGN);
-	__pskb_pull_tail(skb, min(len, NIU_RXPULL_MAX));
+	__pskb_pull_tail(skb, min(len, VLAN_ETH_HLEN));

  	rp->rx_packets++;
  	rp->rx_bytes += skb->len;
-- 
On 10/21/09 04:09 PM, David Miller wrote:
> You still forgot your Signed-off-by: tag...
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html


-- 

