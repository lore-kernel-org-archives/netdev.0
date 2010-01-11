From: Alex Badea <abadea@ixiacom.com>
Subject: [PATCH iproute2] ip xfrm policy: allow different tmpl family
Date: Mon, 11 Jan 2010 17:24:04 +0200
Message-ID: <1263223444-14092-1-git-send-email-abadea@ixiacom.com>
Cc: netdev@vger.kernel.org, Alex Badea <abadea@ixiacom.com>
To: shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from ixro-out-rtc.ixiacom.com ([92.87.192.98]:17167 "EHLO
	ixro-ex1.ixiacom.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752071Ab0AKPYJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Jan 2010 10:24:09 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Allow tmpl IP addresses to have a different family than
selector addresses.  This is useful in conjunction with
XFRM_STATE_AF_UNSPEC.

Signed-off-by: Alex Badea <abadea@ixiacom.com>
---

Rather than resetting preferred_family unconditionally, we could
have a new optional keyword for TMPL, e.g. "ip xfrm policy add ...
tmpl unspec mode tunnel ...".  Let me know if that would be preferred.

 ip/xfrm_policy.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/ip/xfrm_policy.c b/ip/xfrm_policy.c
index 11116e5..2788477 100644
--- a/ip/xfrm_policy.c
+++ b/ip/xfrm_policy.c
@@ -201,10 +201,10 @@ static int xfrm_tmpl_parse(struct xfrm_user_tmpl *tmpl,
 				break;
 			}
 			idp = *argv;
+			preferred_family = AF_UNSPEC;
 			xfrm_id_parse(&tmpl->saddr, &tmpl->id, &tmpl->family,
 				      0, &argc, &argv);
-			if (preferred_family == AF_UNSPEC)
-				preferred_family = tmpl->family;
+			preferred_family = tmpl->family;
 		}
 
 		if (!NEXT_ARG_OK())
-- 
1.6.3.3

