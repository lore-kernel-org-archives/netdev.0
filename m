From: Stephen Hemminger <stephen@networkplumber.org>
Subject: [PATCH net-next] ndisc: use netdev_alloc_skb
Date: Wed, 11 Jun 2014 11:31:09 -0700
Message-ID: <20140611113109.4c104592@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f49.google.com ([209.85.160.49]:41458 "EHLO
	mail-pb0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752667AbaFKSbO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Jun 2014 14:31:14 -0400
Received: by mail-pb0-f49.google.com with SMTP id jt11so88639pbb.22
        for <netdev@vger.kernel.org>; Wed, 11 Jun 2014 11:31:13 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

IPv6 neighbor discovery should use netdev_alloc_skb which adds
extra space for headroom. The old code would allocate packet w/o any
additional headroom and force drivers to reallocate and copy the
packet in some cases.

Signed-off-by: Stephen Hemminger <stephen@networkplumber.org>


--- a/net/ipv6/ndisc.c	2014-06-03 08:06:35.549942475 -0700
+++ b/net/ipv6/ndisc.c	2014-06-11 08:54:31.729764741 -0700
@@ -375,7 +375,7 @@ static struct sk_buff *ndisc_alloc_skb(s
 	struct sock *sk = dev_net(dev)->ipv6.ndisc_sk;
 	struct sk_buff *skb;
 
-	skb = alloc_skb(hlen + sizeof(struct ipv6hdr) + len + tlen, GFP_ATOMIC);
+	skb = netdev_alloc_skb(dev, hlen + sizeof(struct ipv6hdr) + len + tlen);
 	if (!skb) {
 		ND_PRINTK(0, err, "ndisc: %s failed to allocate an skb\n",
 			  __func__);
@@ -383,7 +383,6 @@ static struct sk_buff *ndisc_alloc_skb(s
 	}
 
 	skb->protocol = htons(ETH_P_IPV6);
-	skb->dev = dev;
 
 	skb_reserve(skb, hlen + sizeof(struct ipv6hdr));
 	skb_reset_transport_header(skb);
