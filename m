From: Phil Sutter <phil@nwl.cc>
Subject: [iproute PATCH 1/3] tc: pedit: Fix layered op parsing
Date: Wed,  2 Mar 2016 12:20:29 +0100
Message-ID: <1456917631-18447-2-git-send-email-phil@nwl.cc>
References: <1456917631-18447-1-git-send-email-phil@nwl.cc>
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <shemming@brocade.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbyte.nwl.cc ([151.80.46.58]:43424 "EHLO mail.nwl.cc"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754956AbcCBLUq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 2 Mar 2016 06:20:46 -0500
In-Reply-To: <1456917631-18447-1-git-send-email-phil@nwl.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

After lookup of the layered op submodule, pedit would pass argv and argc
including the layered op identifier at first position which confused the
submodule parser. Fix this by calling NEXT_ARG() before calling the
parse_peopt() callback.

Signed-off-by: Phil Sutter <phil@nwl.cc>
---
 tc/m_pedit.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/tc/m_pedit.c b/tc/m_pedit.c
index 4fdd189d7d9c6..455e4ffd4b2bb 100644
--- a/tc/m_pedit.c
+++ b/tc/m_pedit.c
@@ -421,6 +421,7 @@ parse_munge(int *argc_p, char ***argv_p,struct tc_pedit_sel *sel)
 			p = get_pedit_kind(k);
 			if (NULL == p)
 				goto bad_val;
+			NEXT_ARG();
 			res = p->parse_peopt(&argc, &argv, sel,&tkey);
 			if (res < 0) {
 				fprintf(stderr,"bad pedit parsing\n");
-- 
2.7.2
