From: David Ahern <dsa@cumulusnetworks.com>
Subject: [PATCH net-next 0/3] net: ipv6: Improve user experience with multipath routes
Date: Sun, 15 Jan 2017 12:07:03 -0800
Message-ID: <1484510826-2723-1-git-send-email-dsa@cumulusnetworks.com>
Cc: ddutt@cumulusnetworks.com, David Ahern <dsa@cumulusnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f50.google.com ([74.125.83.50]:33878 "EHLO
        mail-pg0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751495AbdAOUH1 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 15 Jan 2017 15:07:27 -0500
Received: by mail-pg0-f50.google.com with SMTP id 14so9289496pgg.1
        for <netdev@vger.kernel.org>; Sun, 15 Jan 2017 12:07:22 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series closes a couple of gaps between IPv4 and IPv6 with respect
to multipath routes.

Patch 1 allows IPv6 multipath routes to be deleted using just the prefix
and length - similar to what IPv4 allows.

Patch 2 removes the nowait arg which is always 0.

Patch 3 allows IPv6 multipath routes to be returned encoded in the
RTA_MULTIPATH attribute as opposed to a series of single routes.

Backwards compatibility for both patch 1 and 3 is maintained by
requiring users to opt in to the new behavior via change in the
request sent to the kernel.

David Ahern (3):
  net: ipv6: Allow shorthand delete of all nexthops in multipath route
  net: ipv6: remove nowait arg to rt6_fill_node
  net: ipv6: Add option to dump multipath routes via RTA_MULTIPATH
    attribute

 include/linux/mroute6.h        |   2 +-
 include/net/ip6_fib.h          |   4 +-
 include/net/ip6_route.h        |   1 +
 include/uapi/linux/rtnetlink.h |   1 +
 net/ipv6/ip6_fib.c             |  29 +++++++-
 net/ipv6/ip6mr.c               |   9 +--
 net/ipv6/route.c               | 152 +++++++++++++++++++++++++++++++----------
 7 files changed, 153 insertions(+), 45 deletions(-)

-- 
2.1.4
