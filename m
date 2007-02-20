From: Noriaki TAKAMIYA <takamiya@po.ntts.co.jp>
Subject: Re: [RFC][PATCH][IPSEC][2/3] IPv6 over IPv4 IPsec tunnel
Date: Tue, 20 Feb 2007 12:24:32 +0900 (JST)
Message-ID: <20070220.122432.796987476.takamiya@po.ntts.co.jp>
References: <20061229144712.e154b021.kazunori@miyazawa.org>
	<200702101225.33939.nakam@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: kazunori@miyazawa.org, miika@iki.fi, Diego.Beltrami@hiit.fi,
	herbert@gondor.apana.org.au, davem@davemloft.net,
	netdev@vger.kernel.org, usagi-core@linux-ipv6.org,
	nakam@linux-ipv6.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail2.ics.ntts.co.jp ([202.32.24.42]:49298 "EHLO
	mail2.ics.ntts.co.jp" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965643AbXBTD0Y (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Feb 2007 22:26:24 -0500
In-Reply-To: <200702101225.33939.nakam@linux-ipv6.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

  More fix is needed for __xfrm6_bundle_create().

Signed-off-by: Noriaki TAKAMIYA <takamiya@po.ntts.co.jp>
Acked-by: Masahide NAKAMURA <nakam@linux-ipv6.org>
  
--------------------------------------------------
  fixed to set fl_tunnel.fl6_src correctly in xfrm6_bundle_create().

---
 net/ipv6/xfrm6_policy.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/ipv6/xfrm6_policy.c b/net/ipv6/xfrm6_policy.c
index b1133f2..d8a585b 100644
--- a/net/ipv6/xfrm6_policy.c
+++ b/net/ipv6/xfrm6_policy.c
@@ -189,7 +189,7 @@ __xfrm6_bundle_create(struct xfrm_policy
 			case AF_INET6:
 				ipv6_addr_copy(&fl_tunnel.fl6_dst, __xfrm6_bundle_addr_remote(xfrm[i], &fl->fl6_dst));
 
-				ipv6_addr_copy(&fl_tunnel.fl6_src, __xfrm6_bundle_addr_remote(xfrm[i], &fl->fl6_src));
+				ipv6_addr_copy(&fl_tunnel.fl6_src, __xfrm6_bundle_addr_local(xfrm[i], &fl->fl6_src));
 				break;
 			default:
 				BUG_ON(1);
-- 
Noriaki TAKAMIYA
