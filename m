From: Florian Westphal <fw@strlen.de>
Subject: [PATCH 1/1] tc: filter: fix default 'protocol all' on little-endian platforms
Date: Wed, 27 Jul 2011 18:47:05 +0200
Message-ID: <1311785225-23367-1-git-send-email-fw@strlen.de>
Cc: Florian Westphal <fw@strlen.de>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([85.10.199.196]:52401 "EHLO
	Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754857Ab1G0QsY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Jul 2011 12:48:24 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

when specifiying filters without 'protocol' keyword, tc will
default to 'protocol all'.

Unfortunately, this missed a byte-ordering conversion.
---
 tc/tc_filter.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/tc/tc_filter.c b/tc/tc_filter.c
index 919c57c..4e55812 100644
--- a/tc/tc_filter.c
+++ b/tc/tc_filter.c
@@ -73,7 +73,7 @@ int tc_filter_modify(int cmd, unsigned flags, int argc, char **argv)
 	req.t.tcm_family = AF_UNSPEC;
 
 	if (cmd == RTM_NEWTFILTER && flags & NLM_F_CREATE)
-		protocol = ETH_P_ALL;
+		protocol = htons(ETH_P_ALL);
 
 	while (argc > 0) {
 		if (strcmp(*argv, "dev") == 0) {
-- 
1.7.3.4

