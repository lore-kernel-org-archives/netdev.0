From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: linux 3.13: problems with isatap tunnel device and UFO
Date: Mon, 17 Feb 2014 17:09:16 +0100
Message-ID: <20140217160916.GE22833@order.stressinduktion.org>
References: <1682505.dP4nT04FC9@h2o.as.studentenwerk.mhn.de> <1581659.JtJ1UQaXJr@h2o.as.studentenwerk.mhn.de> <20140211024403.GE11150@order.stressinduktion.org> <5911515.kv7YDRiZP1@h2o.as.studentenwerk.mhn.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: netdev@vger.kernel.org, xiyou.wangcong@gmail.com
To: Wolfgang Walter <linux@stwm.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:32827 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750939AbaBQQJR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Feb 2014 11:09:17 -0500
Content-Disposition: inline
In-Reply-To: <5911515.kv7YDRiZP1@h2o.as.studentenwerk.mhn.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

[+Cc Cong Wang]

Hi Cong!

In commit d949d826c09fb ("ipv6: Add generic UDP Tunnel segmentation") you
patched ip6_offload.c:

@@ -126,7 +128,7 @@ static struct sk_buff *ipv6_gso_segment(struct sk_buff *skb,
                ipv6h = ipv6_hdr(skb);
                ipv6h->payload_len = htons(skb->len - skb->mac_len -
                                           sizeof(*ipv6h));
-               if (proto == IPPROTO_UDP) {
+               if (!tunnel && proto == IPPROTO_UDP) {
                        unfrag_ip6hlen = ip6_find_1stfragopt(skb, &prevhdr);
                        fptr = (struct frag_hdr *)(skb_network_header(skb) +
                                unfrag_ip6hlen);


I wonder about the !tunnel exception. This now seems to be a problem in sit
ufo output path, where we don't update fragmentation offsets any more thus
generating invalid frames.

I am not too firm with segmentation in case of tunnels but don't we need to
always update the fragmentation offset no matter what, if upper gso callback
produced more segments?

I'll try to dig deeper...

Thanks,

  Hannes
