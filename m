From: David Ward <david.ward@ll.mit.edu>
Subject: [PATCH 0/2] Fixes to flow cache for AF-specifc flowi structs
Date: Sun, 4 Sep 2011 09:07:19 -0400
Message-ID: <1315141641-3120-1-git-send-email-david.ward@ll.mit.edu>
References: <alpine.LFD.2.00.1109031004500.1492@ja.ssi.bg>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Julian Anastasov <ja@ssi.bg>, David Ward <david.ward@ll.mit.edu>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from MX2.LL.MIT.EDU ([129.55.12.46]:37499 "EHLO mx2.ll.mit.edu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753833Ab1IDNlS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 4 Sep 2011 09:41:18 -0400
In-Reply-To: <alpine.LFD.2.00.1109031004500.1492@ja.ssi.bg>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

These fixes to the flow cache are needed with the conversion to AF-specific
flowi structs. They are written so as to avoid introducing AF-specific code
into net/core/flow.c.

Note that __xfrm_policy_check (in net/xfrm/xfrm_policy.c) still allocates a
struct flowi on the stack and passes it to flow_cache_lookup. My understanding
is that since this is on the stack, this will not be aligned, and therefore it
will cause problems with flow_hash_code and flow_key_compare. Is that correct?

Signed-off-by: David Ward <david.ward@ll.mit.edu>

David Ward (2):
  net: Align AF-specific flowi structs to long
  net: Handle different key sizes between address families in flow
    cache

 include/net/flow.h |   25 ++++++++++++++++++++++---
 net/core/flow.c    |   28 ++++++++++++++++------------
 2 files changed, 38 insertions(+), 15 deletions(-)
