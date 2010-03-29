From: Timo Teras <timo.teras@iki.fi>
Subject: [PATCH 0/7] caching bundles, iteration 2
Date: Mon, 29 Mar 2010 17:12:37 +0300
Message-ID: <1269871964-5412-1-git-send-email-timo.teras@iki.fi>
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
	Timo Teras <timo.teras@iki.fi>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ew0-f220.google.com ([209.85.219.220]:35953 "EHLO
	mail-ew0-f220.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752347Ab0C2OM6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 29 Mar 2010 10:12:58 -0400
Received: by ewy20 with SMTP id 20so705343ewy.1
        for <netdev@vger.kernel.org>; Mon, 29 Mar 2010 07:12:56 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is the current dump of my working tree. The first three
patches should be good already.

The patches 4-7 are more of experimental. And patch 6 has
currently a "bundle leak". If we have per-socket policy that
results in requiring a bundle, it's never freed. I'm not yet
exactly sure how to deal with that. Probably should keep the
bundles not associated with a flow cache entry in their own
global list, which should get garbage collected periodically.

Timo Teras (7):
  xfrm: remove policy lock when accessing policy->walk.dead
  flow: structurize flow cache
  flow: allocate hash table for online cpus only
  flow: delayed deletion of flow cache entries
  flow: virtualize get and entry deletion methods
  xfrm: cache bundles instead of policies for outgoing flows
  xfrm: remove policy garbage collection

 include/net/flow.h      |   18 +-
 include/net/xfrm.h      |   12 +-
 net/core/flow.c         |  442 +++++++++++++++----------
 net/ipv4/xfrm4_policy.c |   22 --
 net/ipv6/xfrm6_policy.c |   31 --
 net/xfrm/xfrm_policy.c  |  831 ++++++++++++++++++++++++-----------------------
 net/xfrm/xfrm_user.c    |    6 +-
 7 files changed, 712 insertions(+), 650 deletions(-)

