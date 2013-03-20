From: Thomas Egerer <hakke_007@gmx.de>
Subject: Re: [PATCH] ip xfrm state: Allow different selector family
Date: Wed, 20 Mar 2013 10:18:57 +0100
Message-ID: <51497F01.9030702@gmx.de>
References: <5145A141.8000707@gmx.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: stephen.hemminger@vyatta.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.gmx.net ([212.227.17.20]:52076 "EHLO mout.gmx.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750763Ab3CTJSj (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 20 Mar 2013 05:18:39 -0400
Received: from mailout-de.gmx.net ([10.1.76.35]) by mrigmx.server.lan
 (mrigmx002) with ESMTP (Nemesis) id 0MW5VH-1UBEzk39tR-00XKPs for
 <netdev@vger.kernel.org>; Wed, 20 Mar 2013 10:18:37 +0100
In-Reply-To: <5145A141.8000707@gmx.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

My previous commit introduced a patch to allow for states with different
ip address families for selector and id. The must have somehow been a
mixup of the patch I tested and the one I send, so the patch sent breaks
the iproute2 build. This patch fixes this. My apologies.

Signed-off-by: Thomas Egerer <hakke_007@gmx.de>
---
Hi Stephen, *,

my sincere apologies for breaking the build. But I somehow build and tested
one commit and sent the wrong one to the list. The assignment was wrong.
This commit fixes this bug. My bad,

Thomas


 ip/xfrm_state.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)



0001-ip-xfrm-state-Fix-assignment-of-preferred_family.patch

diff --git a/ip/xfrm_state.c b/ip/xfrm_state.c
index 6ff5b51..c0cf88c 100644
--- a/ip/xfrm_state.c
+++ b/ip/xfrm_state.c
@@ -296,7 +296,7 @@ static int xfrm_state_modify(int cmd, unsigned flags, int argc, char **argv)
 			NEXT_ARG();
 			preferred_family = AF_UNSPEC;
 			xfrm_selector_parse(&req.xsinfo.sel, &argc, &argv);
-			preferred_family = req.xsinfo.sel;
+			preferred_family = req.xsinfo.sel.family;
 		} else if (strcmp(*argv, "limit") == 0) {
 			NEXT_ARG();
 			xfrm_lifetime_cfg_parse(&req.xsinfo.lft, &argc, &argv);
