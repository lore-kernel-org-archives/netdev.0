From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
	<yoshfuji@linux-ipv6.org>
Subject: [PATCH] [IPV6] XFRM: Fix auditing rt6i_flags; use RTF_xxx flags
 instead of RTCF_xxx.
Date: Fri, 07 Dec 2007 10:41:48 -0800 (PST)
Message-ID: <20071207.104148.112502523.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: yoshfuji@linux-ipv6.org, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from yue.linux-ipv6.org ([203.178.140.15]:43037 "EHLO
	yue.st-paulia.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753222AbXLGSl1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 7 Dec 2007 13:41:27 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

RTCF_xxx flags, defined in include/linux/in_route.h) are available for
IPv4 route (rtable) entries only.  Use RTF_xxx flags instead,
defined in include/linux/ipv6_route.h, for IPv6 route entries (rt6_info).

Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>

--
diff --git a/net/ipv6/xfrm6_policy.c b/net/ipv6/xfrm6_policy.c
index 82e27b8..b8e9eb4 100644
--- a/net/ipv6/xfrm6_policy.c
+++ b/net/ipv6/xfrm6_policy.c
@@ -233,7 +233,7 @@ __xfrm6_bundle_create(struct xfrm_policy *policy, struct xfrm_state **xfrm, int
 		dst_prev->output = dst_prev->xfrm->outer_mode->afinfo->output;
 		/* Sheit... I remember I did this right. Apparently,
 		 * it was magically lost, so this code needs audit */
-		x->u.rt6.rt6i_flags    = rt0->rt6i_flags&(RTCF_BROADCAST|RTCF_MULTICAST|RTCF_LOCAL);
+		x->u.rt6.rt6i_flags    = rt0->rt6i_flags&(RTF_ANYCAST|RTF_LOCAL);
 		x->u.rt6.rt6i_metric   = rt0->rt6i_metric;
 		x->u.rt6.rt6i_node     = rt0->rt6i_node;
 		x->u.rt6.rt6i_gateway  = rt0->rt6i_gateway;

-- 
YOSHIFUJI Hideaki @ USAGI Project  <yoshfuji@linux-ipv6.org>
GPG-FP  : 9022 65EB 1ECF 3AD1 0BDF  80D8 4807 F894 E062 0EEA
