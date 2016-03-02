From: Phil Sutter <phil@nwl.cc>
Subject: [iproute PATCH 3/3] tc: pedit: Fix retain value for ihl adjustments
Date: Wed,  2 Mar 2016 12:20:31 +0100
Message-ID: <1456917631-18447-4-git-send-email-phil@nwl.cc>
References: <1456917631-18447-1-git-send-email-phil@nwl.cc>
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <shemming@brocade.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbyte.nwl.cc ([151.80.46.58]:58900 "EHLO mail.nwl.cc"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755034AbcCBLU5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 2 Mar 2016 06:20:57 -0500
In-Reply-To: <1456917631-18447-1-git-send-email-phil@nwl.cc>
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
index 08fdbaa41fbf4..10e4bebc71d94 100644
--- a/tc/p_ip.c
+++ b/tc/p_ip.c
@@ -58,7 +58,7 @@ parse_ip(int *argc_p, char ***argv_p,struct tc_pedit_sel *sel,struct tc_pedit_ke
 	if (strcmp(*argv, "ihl") == 0) {
 		NEXT_ARG();
 		tkey->off = 0;
-		res = parse_cmd(&argc, &argv, 1, TU32,RU8,sel,tkey);
+		res = parse_cmd(&argc, &argv, 1, TU32,0x0f,sel,tkey);
 		goto done;
 	}
 	if (strcmp(*argv, "protocol") == 0) {
-- 
2.7.2
