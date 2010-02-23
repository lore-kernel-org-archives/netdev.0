From: Shan Wei <shanwei@cn.fujitsu.com>
Subject: Re: [RFC] IPv6: don't forward unspecified frames
Date: Tue, 23 Feb 2010 13:11:33 +0800
Message-ID: <4B836385.8090509@cn.fujitsu.com>
References: <20100222173153.79190176@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:59939 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1750699Ab0BWFLa (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 23 Feb 2010 00:11:30 -0500
In-Reply-To: <20100222173153.79190176@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Stephen Hemminger wrote, at 02/23/2010 09:31 AM:
> This showed up during UNH IPv6 conformance tests. It appears kernel
> incorrectly forwards packets with unspecified source address.

Which case? Is it about spec.p2#18 of IPv6 Ready Logo Phase 2?
I don't see the phenomenon from spec.p2#18 case.

> This looks like the place to fix this, but still not sure and have
> no easy way to test it since ping6 won't send packet with unspecified
> source address.
> 
> Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

Kernel is coincident with the spec, see following commit.


commit f81b2e7d8cf8c6a52b7a5224c3b89cee5aeb6811
Author: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Date:   Wed Jun 25 16:55:26 2008 +0900

    ipv6: Do not forward packets with the unspecified source address.
    
    RFC4291 2.5.2.
    
    Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>

diff --git a/net/ipv6/ip6_output.c b/net/ipv6/ip6_output.c
index fd7cd1b..871bdec 100644
--- a/net/ipv6/ip6_output.c
+++ b/net/ipv6/ip6_output.c
@@ -498,7 +498,8 @@ int ip6_forward(struct sk_buff *skb)
                int addrtype = ipv6_addr_type(&hdr->saddr);
 
                /* This check is security critical. */
-               if (addrtype & (IPV6_ADDR_MULTICAST|IPV6_ADDR_LOOPBACK))
+               if (addrtype == IPV6_ADDR_ANY ||
+                   addrtype & (IPV6_ADDR_MULTICAST | IPV6_ADDR_LOOPBACK))
                        goto error;
                if (addrtype & IPV6_ADDR_LINKLOCAL) {
                        icmpv6_send(skb, ICMPV6_DEST_UNREACH,

-- 
Best Regards
-----
Shan Wei
