From: Allan Stephens <allan.stephens@windriver.com>
Subject: [PATCH 08/13 net-next-2.6] [TIPC]: Prevent display of name table types with no publications
Date: Fri, 30 May 2008 14:20:43 -0400
Message-ID: <1212171648-27122-9-git-send-email-allan.stephens@windriver.com>
References: <1212171648-27122-1-git-send-email-allan.stephens@windriver.com>
Cc: netdev@vger.kernel.org, allan.stephens@windriver.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:50541 "EHLO mail.wrs.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752545AbYE3SXK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 30 May 2008 14:23:10 -0400
In-Reply-To: <1212171648-27122-1-git-send-email-allan.stephens@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds a check to prevent TIPC's name table display code
from listing a name type entry if it exists only to hold subscription
info, rather than published names.

Signed-off-by: Allan Stephens <allan.stephens@windriver.com>
---
 net/tipc/name_table.c |    3 +++
 1 files changed, 3 insertions(+), 0 deletions(-)

diff --git a/net/tipc/name_table.c b/net/tipc/name_table.c
index 892373e..4455f13 100644
--- a/net/tipc/name_table.c
+++ b/net/tipc/name_table.c
@@ -905,6 +905,9 @@ static void nameseq_list(struct name_seq *seq, struct print_buf *buf, u32 depth,
 	struct sub_seq *sseq;
 	char typearea[11];
 
+	if (seq->first_free == 0)
+		return;
+
 	sprintf(typearea, "%-10u", seq->type);
 
 	if (depth == 1) {
-- 
1.5.3.2

