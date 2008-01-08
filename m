From: Masahide NAKAMURA <nakam@linux-ipv6.org>
Subject: [PATCH][XFRM] Statistics: Add outbound-dropping error.
Date: Tue,  8 Jan 2008 13:29:28 +0900
Message-ID: <11997665683729-git-send-email-nakam@linux-ipv6.org>
Cc: herbert@gondor.apana.org.au, netdev@vger.kernel.org,
	Masahide NAKAMURA <nakam@linux-ipv6.org>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from usagi025.linux-ipv6.org ([203.178.140.25]:41094 "EHLO
	triton.linux-ipv6.org" rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org
	with ESMTP id S1753291AbYAHE3h (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Jan 2008 23:29:37 -0500
In-Reply-To: 20071224.160029.100992026.davem@davemloft.net
References: 20071224.160029.100992026.davem@davemloft.net
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,

I found two more points where they should be incremented
as XFRM packet dropping counter. Please apply it.

P.S.
I don't touch XFRM_LOOKUP_ICMP related error at __xfrm_lookup()
since it may not drop the packet.
Correct me if it is wrong or comments are welcomed.


[PATCH][XFRM] Statistics: Add outbound-dropping error.

o Increment PolError counter when flow_cache_lookup() returns
  errored pointer.

o Increment NoStates counter at larval-drop.

Signed-off-by: Masahide NAKAMURA <nakam@linux-ipv6.org>
---
 net/xfrm/xfrm_policy.c |    5 ++++-
 1 files changed, 4 insertions(+), 1 deletions(-)

diff --git a/net/xfrm/xfrm_policy.c b/net/xfrm/xfrm_policy.c
index 280f8de..d83227b 100644
--- a/net/xfrm/xfrm_policy.c
+++ b/net/xfrm/xfrm_policy.c
@@ -1510,8 +1510,10 @@ restart:
 		policy = flow_cache_lookup(fl, dst_orig->ops->family,
 					   dir, xfrm_policy_lookup);
 		err = PTR_ERR(policy);
-		if (IS_ERR(policy))
+		if (IS_ERR(policy)) {
+			XFRM_INC_STATS(LINUX_MIB_XFRMOUTPOLERROR);
 			goto dropdst;
+		}
 	}
 
 	if (!policy)
@@ -1603,6 +1605,7 @@ restart:
 				/* EREMOTE tells the caller to generate
 				 * a one-shot blackhole route.
 				 */
+				XFRM_INC_STATS(LINUX_MIB_XFRMOUTNOSTATES);
 				xfrm_pol_put(policy);
 				return -EREMOTE;
 			}
-- 
1.4.4.2

