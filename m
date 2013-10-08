From: Christophe Gouault <christophe.gouault@6wind.com>
Subject: [PATCH iproute2] xfrm: enable to set non-wildcard mark 0 on SAs and SPs
Date: Tue,  8 Oct 2013 14:56:06 +0200
Message-ID: <1381236966-12436-1-git-send-email-christophe.gouault@6wind.com>
Cc: netdev@vger.kernel.org,
	Christophe Gouault <christophe.gouault@6wind.com>
To: shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 33.106-14-84.ripe.coltfrance.com ([84.14.106.33]:52974 "EHLO
	proxy.6wind.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752665Ab3JHNEn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Oct 2013 09:04:43 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

ip xfrm considers that the user-defined mark is "any" as soon as
(mark.v & mark.m == 0), which prevents from specifying non-wildcard
marks that include the value 0 (typically 0/0xffffffff).

Yet, matching exactly mark 0 is useful for instance to separate
vti policies from global policies.

Always configure the user mark if mark.m != 0.

Signed-off-by: Christophe Gouault <christophe.gouault@6wind.com>
---
 ip/xfrm_policy.c |    2 +-
 ip/xfrm_state.c  |    2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/ip/xfrm_policy.c b/ip/xfrm_policy.c
index 36e33c9..a8d8b98 100644
--- a/ip/xfrm_policy.c
+++ b/ip/xfrm_policy.c
@@ -373,7 +373,7 @@ static int xfrm_policy_modify(int cmd, unsigned flags, int argc, char **argv)
 			  (void *)tmpls_buf, tmpls_len);
 	}
 
-	if (mark.m & mark.v) {
+	if (mark.m) {
 		int r = addattr_l(&req.n, sizeof(req.buf), XFRMA_MARK,
 				  (void *)&mark, sizeof(mark));
 		if (r < 0) {
diff --git a/ip/xfrm_state.c b/ip/xfrm_state.c
index f4ad4cb..c4d2bf6 100644
--- a/ip/xfrm_state.c
+++ b/ip/xfrm_state.c
@@ -528,7 +528,7 @@ static int xfrm_state_modify(int cmd, unsigned flags, int argc, char **argv)
 		exit(1);
 	}
 
-	if (mark.m & mark.v) {
+	if (mark.m) {
 		int r = addattr_l(&req.n, sizeof(req.buf), XFRMA_MARK,
 				  (void *)&mark, sizeof(mark));
 		if (r < 0) {
-- 
1.7.10.4
