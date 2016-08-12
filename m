From: Simon Horman <simon.horman@netronome.com>
Subject: [PATCH net v2] gre: set inner_protocol on xmit
Date: Fri, 12 Aug 2016 17:14:43 +0200
Message-ID: <1471014883-25399-1-git-send-email-simon.horman@netronome.com>
Cc: netdev@vger.kernel.org,
	Alexander Duyck <alexander.duyck@gmail.com>,
	Simon Horman <simon.horman@netronome.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f46.google.com ([74.125.82.46]:37385 "EHLO
	mail-wm0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751340AbcHLPOy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Aug 2016 11:14:54 -0400
Received: by mail-wm0-f46.google.com with SMTP id i5so40413350wmg.0
        for <netdev@vger.kernel.org>; Fri, 12 Aug 2016 08:14:53 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ensure that the inner_protocol is set on transmit so that GSO segmentation,
which relies on that field, works correctly.

I have observed this is not the case when OvS transmits GRE using
lwtunnel metadata (which it always does).

Fixes: 38720352412a ("gre: Use inner_proto to obtain inner header protocol")
Acked-by: Alexander Duyck <alexander.h.duyck@intel.com>
Signed-off-by: Simon Horman <simon.horman@netronome.com>
---
v2
* Added Alexander's Ack
* Drop RFC designation
---
 net/ipv4/ip_gre.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/net/ipv4/ip_gre.c b/net/ipv4/ip_gre.c
index 5b1481be0282..1571b71448a0 100644
--- a/net/ipv4/ip_gre.c
+++ b/net/ipv4/ip_gre.c
@@ -451,6 +451,7 @@ static void gre_fb_xmit(struct sk_buff *skb, struct net_device *dev,
 
 	df = key->tun_flags & TUNNEL_DONT_FRAGMENT ?  htons(IP_DF) : 0;
 
+	skb_set_inner_protocol(skb, proto);
 	iptunnel_xmit(skb->sk, rt, skb, fl.saddr, key->u.ipv4.dst, IPPROTO_GRE,
 		      key->tos, key->ttl, df, false);
 	return;
-- 
2.7.0.rc3.207.g0ac5344
