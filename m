From: Simon Horman <horms@verge.net.au>
Subject: [PATCH v16 4/4] datapath: Enable multiple levels of MPLS pop
Date: Tue, 30 Jul 2013 10:14:33 +0900
Message-ID: <1375146873-3192-5-git-send-email-horms@verge.net.au>
References: <1375146873-3192-1-git-send-email-horms@verge.net.au>
Cc: Ravi K <rkerur@gmail.com>, Isaku Yamahata <yamahata@valinux.co.jp>,
	Jesse Gross <jesse@nicira.com>,
	Pravin B Shelar <pshelar@nicira.com>,
	jarno.rajahalme@nsn.com, Joe Stringer <joe@wand.net.nz>
To: dev@openvswitch.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from kirsty.vergenet.net ([202.4.237.240]:39573 "EHLO
	kirsty.vergenet.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756495Ab3G3BPf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 29 Jul 2013 21:15:35 -0400
In-Reply-To: <1375146873-3192-1-git-send-email-horms@verge.net.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is now sane as recirculation is implemented

Signed-off-by: Simon Horman <horms@verge.net.au>

---

v16
* First post
---
 datapath/datapath.c | 11 +----------
 1 file changed, 1 insertion(+), 10 deletions(-)

diff --git a/datapath/datapath.c b/datapath/datapath.c
index c8143b9..eb14b23 100644
--- a/datapath/datapath.c
+++ b/datapath/datapath.c
@@ -1007,16 +1007,7 @@ static int validate_and_copy_actions__(const struct nlattr *attr,
 				if (!eth_p_mpls(eth_types->types[i]))
 					return -EINVAL;
 
-			/* Disallow subsequent L2.5+ set and mpls_pop actions
-			 * as there is no check here to ensure that the new
-			 * eth_type is valid and thus set actions could
-			 * write off the end of the packet or otherwise
-			 * corrupt it.
-			 *
-			 * Support for these actions is planned using packet
-			 * recirculation.
-			 */
-			eth_types_set(eth_types, htons(0));
+			eth_types_set(eth_types, nla_get_be16(a));
 			break;
 		}
 
-- 
1.8.3.2
