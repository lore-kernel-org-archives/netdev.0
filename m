From: Phil Sutter <phil@nwl.cc>
Subject: [iproute PATCH v2 3/4] tc: pedit: Fix raw op
Date: Tue, 22 Mar 2016 15:16:23 +0100
Message-ID: <1458656184-22154-4-git-send-email-phil@nwl.cc>
References: <1458656184-22154-1-git-send-email-phil@nwl.cc>
Cc: Jamal Hadi Salim <jhs@mojatatu.com>, netdev@vger.kernel.org
To: Stephen Hemminger <shemming@brocade.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbyte.nwl.cc ([151.80.46.58]:51820 "EHLO mail.nwl.cc"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758771AbcCVORC (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 22 Mar 2016 10:17:02 -0400
In-Reply-To: <1458656184-22154-1-git-send-email-phil@nwl.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The retain value was wrong for u16 and u8 types.

Signed-off-by: Phil Sutter <phil@nwl.cc>
---
 tc/m_pedit.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/tc/m_pedit.c b/tc/m_pedit.c
index 30a6f3673e896..8ccec8bc4a99f 100644
--- a/tc/m_pedit.c
+++ b/tc/m_pedit.c
@@ -339,12 +339,12 @@ parse_offset(int *argc_p, char ***argv_p, struct tc_pedit_sel *sel, struct tc_pe
 	}
 	if (matches(*argv, "u16") == 0) {
 		len = 2;
-		retain = 0x0;
+		retain = 0xffff;
 		goto done;
 	}
 	if (matches(*argv, "u8") == 0) {
 		len = 1;
-		retain = 0x0;
+		retain = 0xff;
 		goto done;
 	}
 
-- 
2.7.2
