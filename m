From: Timo Teras <timo.teras@iki.fi>
Subject: [PATCH 0/4] caching bundles, iteration 5
Date: Wed,  7 Apr 2010 13:30:03 +0300
Message-ID: <1270636207-20933-1-git-send-email-timo.teras@iki.fi>
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
	Timo Teras <timo.teras@iki.fi>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ey-out-2122.google.com ([74.125.78.27]:31885 "EHLO
	ey-out-2122.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757730Ab0DGKaQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Apr 2010 06:30:16 -0400
Received: by ey-out-2122.google.com with SMTP id d26so103159eyd.19
        for <netdev@vger.kernel.org>; Wed, 07 Apr 2010 03:30:14 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Changes:
- ops->delete() is now called if flow_cache_genid was changed to
  ensure that resolver does not use stale data
- removed bumping of policy->genid when inserting new policy since
  flow_cache_genid ensures everything is regenerated (thanks Herbert!)
- added unlikely/likely to flow_cache_lookup to favor fast path
  (cache hit)
- added herbert's ack to 1/4 

Compiles, boots and VPN goes up on my test box. Earlier iterations
tested to stay up 3+ days without noticing leaks or other problems.

Timo Teras (4):
  flow: virtualize flow cache entry methods
  xfrm: cache bundles instead of policies for outgoing flows
  xfrm: remove policy garbage collection
  flow: delayed deletion of flow cache entries

 include/net/flow.h      |   23 ++-
 include/net/xfrm.h      |   12 +-
 net/core/flow.c         |  212 ++++++++-----
 net/ipv4/xfrm4_policy.c |   22 --
 net/ipv6/xfrm6_policy.c |   31 --
 net/xfrm/xfrm_policy.c  |  820 +++++++++++++++++++++++++----------------------
 6 files changed, 591 insertions(+), 529 deletions(-)

