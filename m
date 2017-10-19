From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next] ipv4: ipv4_default_advmss() should use route mtu
Date: Wed, 18 Oct 2017 17:02:03 -0700
Message-ID: <1508371323.31614.156.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f194.google.com ([209.85.192.194]:48384 "EHLO
        mail-pf0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750975AbdJSACF (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 18 Oct 2017 20:02:05 -0400
Received: by mail-pf0-f194.google.com with SMTP id b79so5152968pfk.5
        for <netdev@vger.kernel.org>; Wed, 18 Oct 2017 17:02:05 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

ipv4_default_advmss() incorrectly uses the device MTU instead
of the route provided one. IPv6 has the proper behavior,
lets harmonize the two protocols.

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 net/ipv4/route.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index 4306db8273742f5e845635419c296823301c4a8b..bc40bd4111969f640603dd7c5b04fdb7fdcd4afd 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -1250,7 +1250,7 @@ static void set_class_tag(struct rtable *rt, u32 tag)
 static unsigned int ipv4_default_advmss(const struct dst_entry *dst)
 {
 	unsigned int header_size = sizeof(struct tcphdr) + sizeof(struct iphdr);
-	unsigned int advmss = max_t(unsigned int, dst->dev->mtu - header_size,
+	unsigned int advmss = max_t(unsigned int, ipv4_mtu(dst) - header_size,
 				    ip_rt_min_advmss);
 
 	return min(advmss, IPV4_MAX_PMTU - header_size);
