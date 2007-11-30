From: Wang Chen <wangchen@cn.fujitsu.com>
Subject: [PATCH 3/3] [UDP6]: Counter increment on BH mode
Date: Fri, 30 Nov 2007 11:24:05 +0800
Message-ID: <474F8255.5060501@cn.fujitsu.com>
References: <474F7EE8.2040009@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, andi@firstfloor.org, netdev@vger.kernel.org,
	gerrit@erg.abdn.ac.uk, Wang Chen <wangchen@cn.fujitsu.com>
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from [222.73.24.84] ([222.73.24.84]:56323 "EHLO song.cn.fujitsu.com"
	rhost-flags-FAIL-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1753002AbXK3D0z (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 29 Nov 2007 22:26:55 -0500
In-Reply-To: <474F7EE8.2040009@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

(This patch base on "PATCH 2/3".)

UDP_MIB_INERRORS increment is in different way for IPv4
and IPv6. For the consistence, change UDP6_INC_STATS_USER
to UDP6_INC_STATS_BH.

Signed-off-by: Wang Chen <wangchen@cn.fujitsu.com>
---
 udp.c |    2 +-
 1 files changed, 1 insertion(+), 1 deletion(-)

--- linux-2.6.24.rc3.org/net/ipv6/udp.c	2007-11-30 10:38:36.000000000 +0800
+++ linux-2.6.24.rc3/net/ipv6/udp.c	2007-11-30 10:39:01.000000000 +0800
@@ -207,7 +207,7 @@ out:
 	return err;
 
 csum_copy_err:
-	UDP6_INC_STATS_USER(UDP_MIB_INERRORS, is_udplite);
+	UDP6_INC_STATS_BH(UDP_MIB_INERRORS, is_udplite);
 	skb_kill_datagram(sk, skb, flags);
 
 	if (flags & MSG_DONTWAIT)

