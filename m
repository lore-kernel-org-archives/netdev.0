From: Paul Gortmaker <paul.gortmaker@windriver.com>
Subject: [PATCH net-next 04/28] tipc: Initialize peer session field of newly created link endpoint
Date: Sat, 17 Sep 2011 23:32:00 -0400
Message-ID: <1316316744-29514-5-git-send-email-paul.gortmaker@windriver.com>
References: <1316316744-29514-1-git-send-email-paul.gortmaker@windriver.com>
Cc: netdev@vger.kernel.org, allan.stephens@windriver.com,
	ying.xue@windriver.com,
	Paul Gortmaker <paul.gortmaker@windriver.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:49962 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753603Ab1IRDcn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 17 Sep 2011 23:32:43 -0400
In-Reply-To: <1316316744-29514-1-git-send-email-paul.gortmaker@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Allan Stephens <allan.stephens@windriver.com>

Initializes the peer session number field of a newly created link
endpoint to an invalid value. This eliminates the remote possibility
that it will accidentally match the session number used by the peer
the first time the link is activated, and cause the link to ignore
a valid RESET message.

Signed-off-by: Allan Stephens <allan.stephens@windriver.com>
Signed-off-by: Paul Gortmaker <paul.gortmaker@windriver.com>
---
 net/tipc/link.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/net/tipc/link.c b/net/tipc/link.c
index 4cb500b..e0bf6d5 100644
--- a/net/tipc/link.c
+++ b/net/tipc/link.c
@@ -341,6 +341,7 @@ struct link *tipc_link_create(struct tipc_node *n_ptr,
 	memcpy(&l_ptr->media_addr, media_addr, sizeof(*media_addr));
 	l_ptr->owner = n_ptr;
 	l_ptr->checkpoint = 1;
+	l_ptr->peer_session = INVALID_SESSION;
 	l_ptr->b_ptr = b_ptr;
 	link_set_supervision_props(l_ptr, b_ptr->media->tolerance);
 	l_ptr->state = RESET_UNKNOWN;
-- 
1.7.4.4
