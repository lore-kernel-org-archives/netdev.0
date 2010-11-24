From: David Miller <davem@davemloft.net>
Subject: Re: possible kernel oops from user MSS
Date: Wed, 24 Nov 2010 11:47:53 -0800 (PST)
Message-ID: <20101124.114753.242145402.davem@davemloft.net>
References: <20101110.124119.102563803.davem@davemloft.net>
	<AANLkTin-gXceUQxKvQeP8Nc8oXZDJnyjoFUjYD5x_g_y@mail.gmail.com>
	<4CDDC6EE.2010005@mvista.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: mzhang@mvista.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:46943
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755775Ab0KXTr1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Nov 2010 14:47:27 -0500
In-Reply-To: <4CDDC6EE.2010005@mvista.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Min Zhang <mzhang@mvista.com>
Date: Fri, 12 Nov 2010 14:59:58 -0800

> Regarding commit 7a1abd08d52fdeddb3e9a5a33f2f15cc6a5674d2 ("tcp:
> Increase TCP_MAXSEG socket option minimum"). What is the reason
> TCP_MAXSEG minimum be 64? Isn't the exact be 40 which is
> TCPOLEN_MD5SIG_ALIGNED(20) + TCPOLEN_TSTAMP_ALIGNED(12) + 8?
> 
> Or is it better to use TCP_MIN_MSS from tcp.h:
> 
> /* Minimal accepted MSS. It is (60+60+8) - (20+20). */
> #define TCP_MIN_MSS        88U

Committed to net-2.6:

--------------------
>From c39508d6f118308355468314ff414644115a07f3 Mon Sep 17 00:00:00 2001
From: David S. Miller <davem@davemloft.net>
Date: Wed, 24 Nov 2010 11:47:22 -0800
Subject: [PATCH] tcp: Make TCP_MAXSEG minimum more correct.

Use TCP_MIN_MSS instead of constant 64.

Reported-by: Min Zhang <mzhang@mvista.com>
Signed-off-by: David S. Miller <davem@davemloft.net>
---
 net/ipv4/tcp.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
index 0814199..f15c36a 100644
--- a/net/ipv4/tcp.c
+++ b/net/ipv4/tcp.c
@@ -2246,7 +2246,7 @@ static int do_tcp_setsockopt(struct sock *sk, int level,
 		/* Values greater than interface MTU won't take effect. However
 		 * at the point when this call is done we typically don't yet
 		 * know which interface is going to be used */
-		if (val < 64 || val > MAX_TCP_WINDOW) {
+		if (val < TCP_MIN_MSS || val > MAX_TCP_WINDOW) {
 			err = -EINVAL;
 			break;
 		}
-- 
1.7.3.2

