From: Steven Whitehouse <steve@chygwyn.com>
Subject: [DECNET] Fix input routing bug
Date: Wed, 18 Oct 2006 09:38:17 +0100
Message-ID: <20061018083817.GA26179@fogou.chygwyn.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Patrick Caulfield <patrick@tykepenguin.com>,
	Alan Kemmerer <alan.kemmerer@mittalsteel.com>,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from fogou.chygwyn.com ([195.171.2.24]:8892 "EHLO fogou.chygwyn.com")
	by vger.kernel.org with ESMTP id S932114AbWJRIod (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Oct 2006 04:44:33 -0400
To: David Miller <davem@davemloft.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


This patch fixes a silly bug that has been in the input routing code
for some time. It results in trying to send to a node directly when
the origin of the packet is via the default router.

Its been tested by Alan Kemmerer <alan.kemmerer@mittalsteel.com> who
reported the bug and its a fairly obvious fix for a typo.

Signed-off-by: Steven Whitehouse <swhiteho@redhat.com>
Signed-off-by: Patrick Caulfield <patrick@tykepenguin.com>
Cc: Alan Kemmerer <alan.kemmerer@mittalsteel.com>

diff --git a/net/decnet/dn_route.c b/net/decnet/dn_route.c
index dd0761e..810ab9c 100644
--- a/net/decnet/dn_route.c
+++ b/net/decnet/dn_route.c
@@ -1270,7 +1270,6 @@ #endif
 			goto e_inval;
 
 		res.type = RTN_LOCAL;
-		flags |= RTCF_DIRECTSRC;
 	} else {
 		__le16 src_map = fl.fld_src;
 		free_res = 1;
@@ -1341,7 +1340,7 @@ #endif
 			goto make_route;
 
 		/* Packet was intra-ethernet, so we know its on-link */
-		if (cb->rt_flags | DN_RT_F_IE) {
+		if (cb->rt_flags & DN_RT_F_IE) {
 			gateway = cb->src;
 			flags |= RTCF_DIRECTSRC;
 			goto make_route;
