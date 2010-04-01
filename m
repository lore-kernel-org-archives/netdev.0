From: Timo Teras <timo.teras@iki.fi>
Subject: [PATCH 0/4] caching bundles, iteration 3
Date: Thu,  1 Apr 2010 15:52:16 +0300
Message-ID: <1270126340-30181-1-git-send-email-timo.teras@iki.fi>
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
	Timo Teras <timo.teras@iki.fi>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ew0-f220.google.com ([209.85.219.220]:37371 "EHLO
	mail-ew0-f220.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756507Ab0DAMw0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 1 Apr 2010 08:52:26 -0400
Received: by ewy20 with SMTP id 20so329232ewy.1
        for <netdev@vger.kernel.org>; Thu, 01 Apr 2010 05:52:25 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Applies on top of the previous patches I sent.

Changes to previous iteration:
 - "flow: delayed deletion of flow cache entries" refactored to go
   after the other patches per Herbert's request
 - fixed hlist searching in the above mentioned patch
 - uses now ERR_CAST and other similar functions for better readability
 - added basic gc for per-socket bundles
 - some other minor clean ups

I'm now running this on a test box, with my specific setup, and it
seems to be working pretty well. However, this changes quite a bit
of things, so detailed review is needed.

Timo Teras (4):
  flow: virtualize flow cache entry methods
  xfrm: cache bundles instead of policies for outgoing flows
  xfrm: remove policy garbage collection
  flow: delayed deletion of flow cache entries

 include/net/flow.h      |   18 +-
 include/net/xfrm.h      |   12 +-
 net/core/flow.c         |  203 +++++++-----
 net/ipv4/xfrm4_policy.c |   22 --
 net/ipv6/xfrm6_policy.c |   31 --
 net/xfrm/xfrm_policy.c  |  822 +++++++++++++++++++++++++----------------------
 6 files changed, 583 insertions(+), 525 deletions(-)

