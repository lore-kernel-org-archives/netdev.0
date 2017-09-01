From: Phil Sutter <phil@nwl.cc>
Subject: [iproute PATCH 3/6] Convert harmful calls to strncpy() to strlcpy()
Date: Fri,  1 Sep 2017 18:52:53 +0200
Message-ID: <20170901165256.21459-4-phil@nwl.cc>
References: <20170901165256.21459-1-phil@nwl.cc>
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbyte.nwl.cc ([151.80.46.58]:59865 "EHLO mail.nwl.cc"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752247AbdIAQxq (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 1 Sep 2017 12:53:46 -0400
In-Reply-To: <20170901165256.21459-1-phil@nwl.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch converts spots where manual buffer termination was missing to
strlcpy() since that does what is needed.

Signed-off-by: Phil Sutter <phil@nwl.cc>
---
 genl/ctrl.c     | 2 +-
 ip/ipvrf.c      | 2 +-
 ip/xfrm_state.c | 2 +-
 3 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/genl/ctrl.c b/genl/ctrl.c
index 6abd52582d0d3..448988eb90e2b 100644
--- a/genl/ctrl.c
+++ b/genl/ctrl.c
@@ -313,7 +313,7 @@ static int ctrl_list(int cmd, int argc, char **argv)
 
 		if (matches(*argv, "name") == 0) {
 			NEXT_ARG();
-			strncpy(d, *argv, sizeof (d) - 1);
+			strlcpy(d, *argv, sizeof(d));
 			addattr_l(nlh, 128, CTRL_ATTR_FAMILY_NAME,
 				  d, strlen(d) + 1);
 		} else if (matches(*argv, "id") == 0) {
diff --git a/ip/ipvrf.c b/ip/ipvrf.c
index b74c501e0970c..f9277e1e66bdf 100644
--- a/ip/ipvrf.c
+++ b/ip/ipvrf.c
@@ -74,7 +74,7 @@ static int vrf_identify(pid_t pid, char *name, size_t len)
 			if (end)
 				*end = '\0';
 
-			strncpy(name, vrf, len - 1);
+			strlcpy(name, vrf, len);
 			break;
 		}
 	}
diff --git a/ip/xfrm_state.c b/ip/xfrm_state.c
index e11c93bf1c3b5..4483fb8f71d2c 100644
--- a/ip/xfrm_state.c
+++ b/ip/xfrm_state.c
@@ -125,7 +125,7 @@ static int xfrm_algo_parse(struct xfrm_algo *alg, enum xfrm_attr_type_t type,
 	fprintf(stderr, "warning: ALGO-NAME/ALGO-KEYMAT values will be sent to the kernel promiscuously! (verifying them isn't implemented yet)\n");
 #endif
 
-	strncpy(alg->alg_name, name, sizeof(alg->alg_name));
+	strlcpy(alg->alg_name, name, sizeof(alg->alg_name));
 
 	if (slen > 2 && strncmp(key, "0x", 2) == 0) {
 		/* split two chars "0x" from the top */
-- 
2.13.1
