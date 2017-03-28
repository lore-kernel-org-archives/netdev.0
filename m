From: David Ahern <dsa@cumulusnetworks.com>
Subject: [PATCH net-next 0/7] netconf: Add support for RTM_DELNETCONF
Date: Tue, 28 Mar 2017 14:28:00 -0700
Message-ID: <1490736487-16020-1-git-send-email-dsa@cumulusnetworks.com>
Cc: nicolas.dichtel@6wind.com, David Ahern <dsa@cumulusnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f52.google.com ([209.85.214.52]:35934 "EHLO
        mail-it0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752248AbdC1V2O (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 28 Mar 2017 17:28:14 -0400
Received: by mail-it0-f52.google.com with SMTP id e75so71438051itd.1
        for <netdev@vger.kernel.org>; Tue, 28 Mar 2017 14:28:13 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

netconf notifications are sent as devices register but not when they
are deleted leaving userspace caches out of sync. Add support for
RTM_DELNETCONF to ipv4, ipv6 and mpls.

MPLS is missing RTM_NEWNETCONF as devices are created, so add it as well.

David Ahern (7):
  rtnetlink: Add RTM_DELNETCONF
  net: devinet: Refactor inet_netconf_notify_devconf to take event
  net: devinet: Add support for RTM_DELNETCONF
  net: ipv6: Refactor inet6_netconf_notify_devconf to take event
  net: ipv6: Add support for RTM_DELNETCONF
  net:mpls: Refactor mpls_netconf_notify_devconf to take event
  net: mpls: Send netconf messages on device register and unregister

 include/linux/inetdevice.h     |  4 +--
 include/net/addrconf.h         |  4 +--
 include/uapi/linux/rtnetlink.h |  2 ++
 net/ipv4/devinet.c             | 64 +++++++++++++++++++++++++++---------------
 net/ipv4/ipmr.c                | 12 ++++----
 net/ipv6/addrconf.c            | 53 +++++++++++++++++++++++-----------
 net/ipv6/ip6mr.c               |  9 +++---
 net/mpls/af_mpls.c             | 28 ++++++++++--------
 security/selinux/nlmsgtab.c    |  1 +
 9 files changed, 113 insertions(+), 64 deletions(-)

-- 
2.1.4
