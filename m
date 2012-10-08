From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: [PATCH 2/3] ipv4: Don't create nh exeption when the device mtu is
 smaller than the reported pmtu
Date: Mon, 8 Oct 2012 10:48:18 +0200
Message-ID: <20121008084818.GD15622@secunet.com>
References: <20121008084642.GB15622@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:46796 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754217Ab2JHIsX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 8 Oct 2012 04:48:23 -0400
Content-Disposition: inline
In-Reply-To: <20121008084642.GB15622@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When a local tool like tracepath tries to send packets bigger than
the device mtu, we create a nh exeption and set the pmtu to device
mtu. The device mtu does not expire, so check if the device mtu is
smaller than the reported pmtu and don't crerate a nh exeption in
that case.

Signed-off-by: Steffen Klassert <steffen.klassert@secunet.com>
---
 net/ipv4/route.c |    3 +++
 1 files changed, 3 insertions(+), 0 deletions(-)

diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index 90ba835..741df67 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -909,6 +909,9 @@ static void __ip_rt_update_pmtu(struct rtable *rt, struct flowi4 *fl4, u32 mtu)
 	struct dst_entry *dst = &rt->dst;
 	struct fib_result res;
 
+	if (dst->dev->mtu < mtu)
+		return;
+
 	if (mtu < ip_rt_min_pmtu)
 		mtu = ip_rt_min_pmtu;
 
-- 
1.7.0.4
