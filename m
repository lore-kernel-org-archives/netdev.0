From: Christophe Gouault <christophe.gouault@6wind.com>
Subject: [PATCH net-next v2 0/2] xfrm: scalability enhancements for policy database
Date: Fri,  1 Aug 2014 11:12:26 +0200
Message-ID: <1406884348-12423-1-git-send-email-christophe.gouault@6wind.com>
References: <1399902325-1788-1-git-send-email-christophe.gouault@6wind.com>
Cc: netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>,
	Steffen Klassert <steffen.klassert@secunet.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f171.google.com ([74.125.82.171]:49785 "EHLO
	mail-we0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750753AbaHAJNI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 Aug 2014 05:13:08 -0400
Received: by mail-we0-f171.google.com with SMTP id p10so4019993wes.2
        for <netdev@vger.kernel.org>; Fri, 01 Aug 2014 02:13:04 -0700 (PDT)
In-Reply-To: <1399902325-1788-1-git-send-email-christophe.gouault@6wind.com>
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
- changed configuration API from proc to netlink
---
 include/net/netns/xfrm.h  |  14 +++++++
 include/net/xfrm.h        |   1 +
 include/uapi/linux/xfrm.h |   7 ++++
 net/xfrm/xfrm_hash.h      |  76 ++++++++++++++++++++++++++++++-----
 net/xfrm/xfrm_policy.c    | 143
+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++---
 net/xfrm/xfrm_user.c      |  91
++++++++++++++++++++++++++++++++++++++++--
 6 files changed, 313 insertions(+), 19 deletions(-)
