From: Christophe Gouault <christophe.gouault@6wind.com>
Subject: [ipsec-next v4 0/2] xfrm: scalability enhancements for policy database
Date: Fri, 29 Aug 2014 16:16:03 +0200
Message-ID: <1409321765-2012-1-git-send-email-christophe.gouault@6wind.com>
References: <20140829095431.GF6390@secunet.com>
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Steffen Klassert <steffen.klassert@secunet.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f169.google.com ([74.125.82.169]:64504 "EHLO
	mail-we0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752642AbaH2OQY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 Aug 2014 10:16:24 -0400
Received: by mail-we0-f169.google.com with SMTP id k48so2277415wev.0
        for <netdev@vger.kernel.org>; Fri, 29 Aug 2014 07:16:22 -0700 (PDT)
In-Reply-To: <20140829095431.GF6390@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patchset enables to hash more policies than just non-prefixed
ones: hash policies whose prefix lengths are greater or equal to
configurable thresholds.

These thresholds are configured via netlink message
XFRM_MSG_NEWSPDINFO, attributes XFRMA_SPD_IPV4_HTHRESH and
XFRMA_SPD_IPV6_HTHRESH.

The related iproute2 patch for configuring the thresholds is available
on demand.

Best Regards,
Christophe
----
v2:
- change configuration API from proc to netlink
v3:
- initialize xfrm_policy_hthresh lock
- remove "rebuilding SPD hash table" log
- replace deprecated hlist_add_after by hlist_add_behind
- remove netlink reply to XFRM_MSG_NEWSPDINFO request
v4:
- remove unused variables in xfrm_set_spdinfo
---
 include/net/netns/xfrm.h  |  14 +++++++
 include/net/xfrm.h        |   1 +
 include/uapi/linux/xfrm.h |   7 ++++
 net/xfrm/xfrm_hash.h      |  76 +++++++++++++++++++++++++++++++----- 
 net/xfrm/xfrm_policy.c    | 140 +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++---
 net/xfrm/xfrm_user.c      |  80 ++++++++++++++++++++++++++++++++++++--
 6 files changed, 299 insertions(+), 19 deletions(-)
