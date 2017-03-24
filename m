From: David Ahern <dsa@cumulusnetworks.com>
Subject: [iproute2 net-next v2 0/3] ip netconf improvements
Date: Thu, 23 Mar 2017 19:51:19 -0700
Message-ID: <1490323882-11609-1-git-send-email-dsa@cumulusnetworks.com>
Cc: nicolas.dichtel@6wind.com, David Ahern <dsa@cumulusnetworks.com>
To: netdev@vger.kernel.org, stephen@networkplumber.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f42.google.com ([74.125.83.42]:34671 "EHLO
        mail-pg0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S933818AbdCXCv3 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 23 Mar 2017 22:51:29 -0400
Received: by mail-pg0-f42.google.com with SMTP id 21so1417560pgg.1
        for <netdev@vger.kernel.org>; Thu, 23 Mar 2017 19:51:29 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Currently, ip netconf only shows data for ipv4 and ipv6 for dumps
and just ipv4 for device requests. Improve the user experience by
using the new kernel patch to dump all address families that have
registered. For example, if mpls_router module is loaded then mpls
values are displayed along with ipv4 and ipv6.

If the new feature is not supported (new iproute2 on older kernel)
the kernel returns the nlmsg error EOPNOTSUPP which can be trapped
and fallback to existing behavior.

v2
- fixed index conversion in patch 3 per nicholas' comment

David Ahern (3):
  netlink: Add flag to suppress print of nlmsg error
  ip netconf: Show all address families by default in dumps
  ip netconf: show all families on dev request

 include/libnetlink.h |  1 +
 ip/ipnetconf.c       | 36 +++++++++++++++++++++++++-----------
 lib/libnetlink.c     |  3 ++-
 3 files changed, 28 insertions(+), 12 deletions(-)

-- 
2.1.4
