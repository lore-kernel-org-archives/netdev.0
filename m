From: Patrick McHardy <kaber@trash.net>
Subject: Re: 2.6.20.3-rc1 / iproute2 hoplimit 2^32-1 vs 2^8-1
Date: Mon, 19 Mar 2007 16:20:30 +0100
Message-ID: <45FEAA3E.20601@trash.net>
References: <Pine.LNX.4.64.0703191706530.3331@netcore.fi>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------050404090709020801040401"
Cc: netdev@vger.kernel.org
To: Pekka Savola <pekkas@netcore.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:59021 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965889AbXCSPUd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Mar 2007 11:20:33 -0400
In-Reply-To: <Pine.LNX.4.64.0703191706530.3331@netcore.fi>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------050404090709020801040401
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit

Pekka Savola wrote:
> On kernel based on 2.6.20.3-rc1 (FC6), 'ip -6 r l' shows:
> 
> default via fe80::212:f0ff:fe5f:c4ec dev eth1  proto kernel  metric
> 1024  expires 7191sec mtu 1500 advmss 1440 hoplimit 4294967295
> 
> (this is the same with iproute2-ss061214 and iproute2-ss070313.)
> 
> So, it seems that the data length for hoplimit is not quite right, or
> it's reported as 2^32-1 instead of 2^8-1...


Does this fix it?

Signed-off-by: Patrick McHardy <kaber@trash.net>

--------------050404090709020801040401
Content-Type: text/plain;
 name="x"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="x"

diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index 0e1f4b2..ec347e5 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -1216,7 +1216,7 @@ install_route:
 	}
 
 	if (rt->u.dst.metrics[RTAX_HOPLIMIT-1] == 0)
-		rt->u.dst.metrics[RTAX_HOPLIMIT-1] = -1;
+		rt->u.dst.metrics[RTAX_HOPLIMIT-1] = 255;
 	if (!rt->u.dst.metrics[RTAX_MTU-1])
 		rt->u.dst.metrics[RTAX_MTU-1] = ipv6_get_mtu(dev);
 	if (!rt->u.dst.metrics[RTAX_ADVMSS-1])
@@ -1821,7 +1821,7 @@ struct rt6_info *addrconf_dst_alloc(stru
 	rt->rt6i_idev = idev;
 	rt->u.dst.metrics[RTAX_MTU-1] = ipv6_get_mtu(rt->rt6i_dev);
 	rt->u.dst.metrics[RTAX_ADVMSS-1] = ipv6_advmss(dst_mtu(&rt->u.dst));
-	rt->u.dst.metrics[RTAX_HOPLIMIT-1] = -1;
+	rt->u.dst.metrics[RTAX_HOPLIMIT-1] = 255;
 	rt->u.dst.obsolete = -1;
 
 	rt->rt6i_flags = RTF_UP | RTF_NONEXTHOP;

--------------050404090709020801040401--
