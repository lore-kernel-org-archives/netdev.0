From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] make _minimum_ TCP retransmission timeout configurable
 take 2
Date: Fri, 31 Aug 2007 14:38:55 -0700 (PDT)
Message-ID: <20070831.143855.88699905.davem@davemloft.net>
References: <46D859D9.6030407@hp.com>
	<20070831.115706.97292718.davem@davemloft.net>
	<46D88146.9090401@hp.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: rick.jones2@hp.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:37980
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1761180AbXHaVi4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 31 Aug 2007 17:38:56 -0400
In-Reply-To: <46D88146.9090401@hp.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Rick Jones <rick.jones2@hp.com>
Date: Fri, 31 Aug 2007 13:59:50 -0700

> ip is at tcp_rto_min+0x20/0x40

diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index 1ee7212..bbad2cd 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -560,7 +560,7 @@ static u32 tcp_rto_min(struct sock *sk)
 	struct dst_entry *dst = __sk_dst_get(sk);
 	u32 rto_min = TCP_RTO_MIN;
 
-	if (dst_metric_locked(dst, RTAX_RTO_MIN))
+	if (dst && dst_metric_locked(dst, RTAX_RTO_MIN))
 		rto_min = dst->metrics[RTAX_RTO_MIN-1];
 	return rto_min;
 }
