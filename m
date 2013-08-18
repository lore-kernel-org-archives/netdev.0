From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: About  tcp: set timestamps for restored skb-s
Date: Sat, 17 Aug 2013 17:39:36 -0700
Message-ID: <1376786376.21329.20.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: Andrey Vagin <avagin@openvz.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f43.google.com ([209.85.220.43]:55642 "EHLO
	mail-pa0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751918Ab3HRAji (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 17 Aug 2013 20:39:38 -0400
Received: by mail-pa0-f43.google.com with SMTP id hz10so3298413pad.30
        for <netdev@vger.kernel.org>; Sat, 17 Aug 2013 17:39:38 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Because of gmail.com problems, I missed lot of netdev traffic

Related to :

http://patchwork.ozlabs.org/patch/267678/


diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
index 5423223..b2f6c74 100644
--- a/net/ipv4/tcp.c
+++ b/net/ipv4/tcp.c
@@ -1121,6 +1121,13 @@  new_segment:
 					goto wait_for_memory;
 
 				/*
+				 * All packets are restored as if they have
+				 * already been sent.
+				 */
+				if (tp->repair)
+					TCP_SKB_CB(skb)->when = tcp_time_stamp;
+

The test could be removed.

Setting @when for regular sends seems harmless
