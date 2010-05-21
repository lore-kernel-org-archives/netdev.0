From: Arnd Hannemann <hannemann@nets.rwth-aachen.de>
Subject: [PATCH] iproute2: Add dsfield as alias for tos for ip rules
Date: Fri, 21 May 2010 16:10:09 +0200
Message-ID: <1274451009-29456-1-git-send-email-hannemann@nets.rwth-aachen.de>
Content-Transfer-Encoding: 7BIT
Cc: netdev@vger.kernel.org,
	Arnd Hannemann <hannemann@nets.rwth-aachen.de>
To: shemminger@osdl.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mta-2.ms.rz.RWTH-Aachen.DE ([134.130.7.73]:55986 "EHLO
	mta-2.ms.rz.rwth-aachen.de" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754001Ab0EUOK3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 May 2010 10:10:29 -0400
Received: from ironport-out-1.rz.rwth-aachen.de ([134.130.5.40])
 by mta-2.ms.rz.RWTH-Aachen.de
 (Sun Java(tm) System Messaging Server 6.3-7.04 (built Sep 26 2008))
 with ESMTP id <0L2R00132WPF31E0@mta-2.ms.rz.RWTH-Aachen.de> for
 netdev@vger.kernel.org; Fri, 21 May 2010 16:10:27 +0200 (CEST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Arnd Hannemann <arnd@rhea.(none)>

Get ip rule parsing of "dsfield" in sync with ip route parsing and manual page.

Signed-off-by: Arnd Hannemann <hannemann@nets.rwth-aachen.de>
---
 ip/iprule.c |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/ip/iprule.c b/ip/iprule.c
index 7140375..cbf8226 100644
--- a/ip/iprule.c
+++ b/ip/iprule.c
@@ -270,7 +270,8 @@ static int iprule_modify(int cmd, int argc, char **argv)
 			if (get_u32(&pref, *argv, 0))
 				invarg("preference value is invalid\n", *argv);
 			addattr32(&req.n, sizeof(req), FRA_PRIORITY, pref);
-		} else if (strcmp(*argv, "tos") == 0) {
+		} else if (strcmp(*argv, "tos") == 0 ||
+			   matches(*argv, "dsfield") == 0) {
 			__u32 tos;
 			NEXT_ARG();
 			if (rtnl_dsfield_a2n(&tos, *argv))
-- 
1.7.0.4

