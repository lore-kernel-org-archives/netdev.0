From: David Ahern <dsa@cumulusnetworks.com>
Subject: [iproute2 net-next 0/3] ip netconf improvements
Date: Wed, 22 Mar 2017 14:59:19 -0700
Message-ID: <1490219962-32587-1-git-send-email-dsa@cumulusnetworks.com>
Cc: nicolas.dichtel@6wind.com, David Ahern <dsa@cumulusnetworks.com>
To: netdev@vger.kernel.org, stephen@networkplumber.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f178.google.com ([209.85.192.178]:35242 "EHLO
        mail-pf0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751303AbdCVV72 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 22 Mar 2017 17:59:28 -0400
Received: by mail-pf0-f178.google.com with SMTP id 20so49016483pfk.2
        for <netdev@vger.kernel.org>; Wed, 22 Mar 2017 14:59:27 -0700 (PDT)
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

David Ahern (3):
  netlink: Add flag to suppress print of nlmsg error
  ip netconf: Show all address families by default in dumps
  ip netconf: Show all families on dev request

 include/libnetlink.h |  1 +
 ip/ipnetconf.c       | 36 +++++++++++++++++++++++++-----------
 lib/libnetlink.c     |  3 ++-
 3 files changed, 28 insertions(+), 12 deletions(-)

-- 
2.1.4
