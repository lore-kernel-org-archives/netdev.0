From: Timo Teras <timo.teras@iki.fi>
Subject: [PATCH 0/4] caching bundles, iteration 4
Date: Mon,  5 Apr 2010 10:00:20 +0300
Message-ID: <1270450824-2928-1-git-send-email-timo.teras@iki.fi>
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
	Timo Teras <timo.teras@iki.fi>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ew0-f220.google.com ([209.85.219.220]:45992 "EHLO
	mail-ew0-f220.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750994Ab0DEHAd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Apr 2010 03:00:33 -0400
Received: by ewy20 with SMTP id 20so980470ewy.1
        for <netdev@vger.kernel.org>; Mon, 05 Apr 2010 00:00:31 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Changes since last iteration:
  - wrapped flow_cache_ops* in struct flow_cache_object for
    readability, Herbert's request
  - constified flow_cache_ops, noticed by Eric Dumazet
  - NETDEV_DOWN hook now calls garbage collect function to also process
    per-socket bundles (instead of the plain flow_cache_flush)
  - some coding style fixes

Timo Teras (4):
  flow: virtualize flow cache entry methods
  xfrm: cache bundles instead of policies for outgoing flows
  xfrm: remove policy garbage collection
  flow: delayed deletion of flow cache entries

 include/net/flow.h      |   23 ++-
 include/net/xfrm.h      |   12 +-
 net/core/flow.c         |  201 +++++++-----
 net/ipv4/xfrm4_policy.c |   22 --
 net/ipv6/xfrm6_policy.c |   31 --
 net/xfrm/xfrm_policy.c  |  818 +++++++++++++++++++++++++----------------------
 6 files changed, 584 insertions(+), 523 deletions(-)

