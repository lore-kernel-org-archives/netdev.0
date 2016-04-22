From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 05/23] netfilter: x_tables: assert minimum target size
Date: Fri, 22 Apr 2016 15:39:36 +0200
Message-ID: <1461332394-3994-6-git-send-email-pablo@netfilter.org>
References: <1461332394-3994-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:45212 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753359AbcDVNkJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 22 Apr 2016 09:40:09 -0400
Received: from antivirus1-rhel7.int (unknown [192.168.2.11])
	by mail.us.es (Postfix) with ESMTP id 9B4725B9
	for <netdev@vger.kernel.org>; Fri, 22 Apr 2016 15:40:07 +0200 (CEST)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
	by antivirus1-rhel7.int (Postfix) with ESMTP id 80FD8FAB51
	for <netdev@vger.kernel.org>; Fri, 22 Apr 2016 15:40:07 +0200 (CEST)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
	by antivirus1-rhel7.int (Postfix) with ESMTP id 59A43B505B
	for <netdev@vger.kernel.org>; Fri, 22 Apr 2016 15:40:05 +0200 (CEST)
In-Reply-To: <1461332394-3994-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Westphal <fw@strlen.de>

The target size includes the size of the xt_entry_target struct.

Signed-off-by: Florian Westphal <fw@strlen.de>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/netfilter/x_tables.c | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/net/netfilter/x_tables.c b/net/netfilter/x_tables.c
index 1f44bfa..ec1b718 100644
--- a/net/netfilter/x_tables.c
+++ b/net/netfilter/x_tables.c
@@ -568,6 +568,9 @@ int xt_check_entry_offsets(const void *base,
 		return -EINVAL;
 
 	t = (void *)(e + target_offset);
+	if (t->u.target_size < sizeof(*t))
+		return -EINVAL;
+
 	if (target_offset + t->u.target_size > next_offset)
 		return -EINVAL;
 
-- 
2.1.4
