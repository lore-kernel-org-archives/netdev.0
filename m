From: Kazunori Miyazawa <kazunori@miyazawa.org>
Subject: [PATCH] [IPv6][IPsec] fix oops with using IPsec
Date: Fri, 24 Oct 2003 21:30:58 +0900
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031024213058.47b4a824.kazunori@miyazawa.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: usagi@linux-ipv6.org
Return-path: <netdev-bounce@oss.sgi.com>
To: davem@redhat.com, netdev@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hello,

This patch fixes oops with using IPsec in IPv6. Original source removes
RTF_NDISC at copying dst. It makes the kernel use the wrong stackable
destination.

--- net/ipv6/xfrm6_policy.c.org	2003-10-24 21:17:26.000000000 +0900
+++ net/ipv6/xfrm6_policy.c	2003-10-24 21:17:41.000000000 +0900
@@ -169,7 +169,7 @@
 		dst_prev->output	= dst_prev->xfrm->type->output;
 		/* Sheit... I remember I did this right. Apparently,
 		 * it was magically lost, so this code needs audit */
-		x->u.rt6.rt6i_flags    = rt0->rt6i_flags&(RTCF_BROADCAST|RTCF_MULTICAST|RTCF_LOCAL);
+		x->u.rt6.rt6i_flags    = rt0->rt6i_flags&(RTCF_BROADCAST|RTCF_MULTICAST|RTCF_LOCAL|RTF_NDISC);
 		x->u.rt6.rt6i_metric   = rt0->rt6i_metric;
 		x->u.rt6.rt6i_node     = rt0->rt6i_node;
 		x->u.rt6.rt6i_gateway  = rt0->rt6i_gateway;

--Kazunori Miyazawa
