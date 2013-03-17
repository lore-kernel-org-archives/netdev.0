From: Thomas Egerer <hakke_007@gmx.de>
Subject: [PATCH] ip xfrm state: Allow different selector family
Date: Sun, 17 Mar 2013 11:56:01 +0100
Message-ID: <5145A141.8000707@gmx.de>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------020602060007000004070804"
Cc: stephen.hemminger@vyatta.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.gmx.net ([212.227.17.20]:64903 "EHLO mout.gmx.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756111Ab3CQKzf (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 17 Mar 2013 06:55:35 -0400
Received: from mailout-de.gmx.net ([10.1.76.4]) by mrigmx.server.lan
 (mrigmx002) with ESMTP (Nemesis) id 0Mg2Ch-1U2hCi27gT-00NVIP for
 <netdev@vger.kernel.org>; Sun, 17 Mar 2013 11:55:33 +0100
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------020602060007000004070804
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit


Do not enforce the selector of a state to have the same address family
as the id. This makes it possible to configure inter family states.

Signed-off-by: Thomas Egerer <hakke_007@gmx.de>
---
 ip/xfrm_state.c |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)



--------------020602060007000004070804
Content-Type: text/x-patch;
 name="0001-ip-xfrm-state-Allow-different-selector-family.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
 filename="0001-ip-xfrm-state-Allow-different-selector-family.patch"

diff --git a/ip/xfrm_state.c b/ip/xfrm_state.c
index 8ac3437..aec49d6 100644
--- a/ip/xfrm_state.c
+++ b/ip/xfrm_state.c
@@ -300,7 +300,9 @@ static int xfrm_state_modify(int cmd, unsigned flags, int argc, char **argv)
 			xfrm_state_flag_parse(&req.xsinfo.flags, &argc, &argv);
 		} else if (strcmp(*argv, "sel") == 0) {
 			NEXT_ARG();
+			preferred_family = AF_UNSPEC;
 			xfrm_selector_parse(&req.xsinfo.sel, &argc, &argv);
+			preferred_family = req.xsinfo.sel;
 		} else if (strcmp(*argv, "limit") == 0) {
 			NEXT_ARG();
 			xfrm_lifetime_cfg_parse(&req.xsinfo.lft, &argc, &argv);


--------------020602060007000004070804--
