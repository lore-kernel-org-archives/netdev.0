From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net] tcp: fix get_timewait4_sock() delay computation on 64bit
Date: Thu, 27 Mar 2014 07:19:19 -0700
Message-ID: <1395929959.12610.288.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f171.google.com ([209.85.192.171]:49829 "EHLO
	mail-pd0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753951AbaC0OTV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Mar 2014 10:19:21 -0400
Received: by mail-pd0-f171.google.com with SMTP id r10so3433833pdi.30
        for <netdev@vger.kernel.org>; Thu, 27 Mar 2014 07:19:20 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

It seems I missed one change in get_timewait4_sock() to compute
the remaining time before deletion of IPV4 timewait socket.

This could result in wrong output in /proc/net/tcp for tm->when field.

Fixes: 96f817fedec4 ("tcp: shrink tcp6_timewait_sock by one cache line")
Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 net/ipv4/tcp_ipv4.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index 4555244607d0..6379894ec210 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -2628,7 +2628,7 @@ static void get_timewait4_sock(const struct inet_timewait_sock *tw,
 {
 	__be32 dest, src;
 	__u16 destp, srcp;
-	long delta = tw->tw_ttd - jiffies;
+	s32 delta = tw->tw_ttd - inet_tw_time_stamp();
 
 	dest  = tw->tw_daddr;
 	src   = tw->tw_rcv_saddr;
