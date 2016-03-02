From: Phil Sutter <phil@nwl.cc>
Subject: [iproute PATCH v2 3/4] tc: pedit: Fix retain value for ihl adjustments
Date: Wed,  2 Mar 2016 19:45:42 +0100
Message-ID: <1456944343-19058-4-git-send-email-phil@nwl.cc>
References: <20160302095414.45a928df@xeon-e3>
 <1456944343-19058-1-git-send-email-phil@nwl.cc>
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <shemming@brocade.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbyte.nwl.cc ([151.80.46.58]:47305 "EHLO mail.nwl.cc"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756359AbcCBSqO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 2 Mar 2016 13:46:14 -0500
In-Reply-To: <1456944343-19058-1-git-send-email-phil@nwl.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Since the IP Header Length field is just half a byte, adjust retain to
only match these bits so the Version field is not overwritten by
accident.

The whole concept is actually broken due to dependency on endianness
which pedit ignores.

Signed-off-by: Phil Sutter <phil@nwl.cc>
---
 tc/p_ip.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/tc/p_ip.c b/tc/p_ip.c
index 08fdbaa41fbf4..8f0649134566b 100644
--- a/tc/p_ip.c
+++ b/tc/p_ip.c
@@ -58,7 +58,7 @@ parse_ip(int *argc_p, char ***argv_p,struct tc_pedit_sel *sel,struct tc_pedit_ke
 	if (strcmp(*argv, "ihl") == 0) {
 		NEXT_ARG();
 		tkey->off = 0;
-		res = parse_cmd(&argc, &argv, 1, TU32,RU8,sel,tkey);
+		res = parse_cmd(&argc, &argv, 1, TU32, 0x0f, sel, tkey);
 		goto done;
 	}
 	if (strcmp(*argv, "protocol") == 0) {
-- 
2.7.2
