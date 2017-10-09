From: William Tu <u9012063@gmail.com>
Subject: [net-next 1/3] ip_gre: fix mtu and headroom size
Date: Mon,  9 Oct 2017 13:47:45 -0700
Message-ID: <1507582067-36718-2-git-send-email-u9012063@gmail.com>
References: <1507582067-36718-1-git-send-email-u9012063@gmail.com>
Cc: Tom Herbert <tom@quantonium.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f196.google.com ([209.85.192.196]:35742 "EHLO
        mail-pf0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754295AbdJIUsE (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 9 Oct 2017 16:48:04 -0400
Received: by mail-pf0-f196.google.com with SMTP id i23so30357973pfi.2
        for <netdev@vger.kernel.org>; Mon, 09 Oct 2017 13:48:03 -0700 (PDT)
In-Reply-To: <1507582067-36718-1-git-send-email-u9012063@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The ip_gre_calc_hlen() already counts gre's base header len (4-byte)
plus optional header's len, so tunnel->hlen has the entire gre
headeri + options len. Thus, remove the -4 and +4 when calculating
the needed_headroom and mtu.

Fixes: 4565e9919cda ("gre: Setup and TX path for gre/UDP foo-over-udp encapsulation")
Signed-off-by: William Tu <u9012063@gmail.com>
Cc: Tom Herbert <tom@quantonium.net>
---
 net/ipv4/ip_gre.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/ipv4/ip_gre.c b/net/ipv4/ip_gre.c
index c105a315b1a3..286065c35959 100644
--- a/net/ipv4/ip_gre.c
+++ b/net/ipv4/ip_gre.c
@@ -947,8 +947,8 @@ static void __gre_tunnel_init(struct net_device *dev)
 
 	t_hlen = tunnel->hlen + sizeof(struct iphdr);
 
-	dev->needed_headroom	= LL_MAX_HEADER + t_hlen + 4;
-	dev->mtu		= ETH_DATA_LEN - t_hlen - 4;
+	dev->needed_headroom	= LL_MAX_HEADER + t_hlen;
+	dev->mtu		= ETH_DATA_LEN - t_hlen;
 
 	dev->features		|= GRE_FEATURES;
 	dev->hw_features	|= GRE_FEATURES;
-- 
2.7.4
