From: Simon Horman <simon.horman@netronome.com>
Subject: [PATCH/RFC net] gre: set inner_protocol on xmit
Date: Fri, 12 Aug 2016 11:46:58 +0200
Message-ID: <20160812094656.GA26953@penelope.isobedori.kobe.vergenet.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Simon Horman <simon.horman@netronome.com>,
	Alexander Duyck <aduyck@mirantis.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f52.google.com ([74.125.82.52]:36963 "EHLO
	mail-wm0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752113AbcHLJrB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Aug 2016 05:47:01 -0400
Received: by mail-wm0-f52.google.com with SMTP id i5so21720276wmg.0
        for <netdev@vger.kernel.org>; Fri, 12 Aug 2016 02:47:00 -0700 (PDT)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ensure that the inner_protocol is set on transmit so that GSO segmentation,
which relies on that field, works correctly.

I have observed this is not the case when OvS transmits GRE using
lwtunnel metadata (which it always does).

Fixes: 38720352412a ("gre: Use inner_proto to obtain inner header protocol")
Cc: Alexander Duyck <aduyck@mirantis.com>
Reviewed-by: Dinan Gunawardena <dinan.gunawardena@netronome.com>
Acked-by: Jakub Kicinski <jakub.kicinski@netronome.com>
Signed-off-by: Simon Horman <simon.horman@netronome.com>
---
 net/ipv4/ip_gre.c | 1 +
 1 file changed, 1 insertion(+)
---
 Repost with correct domain vger address

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
