From: David Ward <david.ward@ll.mit.edu>
Subject: [PATCH 0/2] Fixes to flow cache for AF-specifc flowi structs
Date: Mon, 5 Sep 2011 22:47:22 -0400
Message-ID: <1315277244-19335-1-git-send-email-david.ward@ll.mit.edu>
References: <CAHXqBF+eF_zYAFPZv0hWUvDHv5YMHuFAR3-iB8MEZz2G7vCUyA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Julian Anastasov <ja@ssi.bg>,
	=?UTF-8?q?Micha=C5=82=20Miros=C5=82aw?= <mirqus@gmail.com>,
	David Ward <david.ward@ll.mit.edu>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from MX2.LL.MIT.EDU ([129.55.12.46]:60515 "EHLO mx2.ll.mit.edu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751423Ab1IFDLQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 5 Sep 2011 23:11:16 -0400
In-Reply-To: <CAHXqBF+eF_zYAFPZv0hWUvDHv5YMHuFAR3-iB8MEZz2G7vCUyA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

v2: Return the length of the flow key as a multiple of sizeof(flow_compare_t),
    to reduce the number of shift operations.

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
 net/core/flow.c    |   31 +++++++++++++++++--------------
 2 files changed, 39 insertions(+), 17 deletions(-)
