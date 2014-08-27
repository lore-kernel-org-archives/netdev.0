From: Christophe Gouault <christophe.gouault@6wind.com>
Subject: [PATCH ipsec-next v3 0/2] xfrm: scalability enhancements for policy database
Date: Wed, 27 Aug 2014 17:48:13 +0200
Message-ID: <1409154495-1343-1-git-send-email-christophe.gouault@6wind.com>
References: <20140821060944.GC6390@secunet.com>
Cc: netdev@vger.kernel.org
To: Steffen Klassert <steffen.klassert@secunet.com>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f171.google.com ([74.125.82.171]:65117 "EHLO
	mail-we0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S934523AbaH0Pse (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Aug 2014 11:48:34 -0400
Received: by mail-we0-f171.google.com with SMTP id p10so417062wes.30
        for <netdev@vger.kernel.org>; Wed, 27 Aug 2014 08:48:31 -0700 (PDT)
In-Reply-To: <20140821060944.GC6390@secunet.com>
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
---
 include/net/netns/xfrm.h  |  14 +++++++
 include/net/xfrm.h        |   1 +
 include/uapi/linux/xfrm.h |   7 ++++
 net/xfrm/xfrm_hash.h      |  76 +++++++++++++++++++++++++++++++-----
 net/xfrm/xfrm_policy.c    | 140 +++++++++++++++++++++++++++++++++++++++++++++++
 net/xfrm/xfrm_user.c      |  83 +++++++++++++++++++++++++++++++++++++--
 6 files changed, 302 insertions(+), 19 deletions(-)
