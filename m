From: =?ISO-8859-1?Q?Timo_Ter=E4s?= <timo.teras@iki.fi>
Subject: ip_gre headroom allocation
Date: Thu, 11 Jun 2009 11:22:34 +0300
Message-ID: <4A30BECA.8030205@iki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	David Miller <davem@davemloft.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ew0-f210.google.com ([209.85.219.210]:44926 "EHLO
	mail-ew0-f210.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760964AbZFKIWe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Jun 2009 04:22:34 -0400
Received: by ewy6 with SMTP id 6so1776533ewy.37
        for <netdev@vger.kernel.org>; Thu, 11 Jun 2009 01:22:36 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I'm not entirely sure about this, but shouldn't we do something like
the below to make ip_gre allocation enough headroom for paths where
e.g. xfrm transformations take place (as a speed optimization)?

diff --git a/net/ipv4/ip_gre.c b/net/ipv4/ip_gre.c
index e62510d..eb78dd9 100644
--- a/net/ipv4/ip_gre.c
+++ b/net/ipv4/ip_gre.c
@@ -812,7 +812,7 @@ static int ipgre_tunnel_xmit(struct sk_buff *skb, struct net_device *dev)
                        tunnel->err_count = 0;
        }
 
-       max_headroom = LL_RESERVED_SPACE(tdev) + gre_hlen;
+       max_headroom = LL_RESERVED_SPACE(tdev) + gre_hlen + rt->u.dst.header_len;
 
        if (skb_headroom(skb) < max_headroom || skb_shared(skb)||
            (skb_cloned(skb) && !skb_clone_writable(skb, 0))) {
