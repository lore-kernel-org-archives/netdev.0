From: David Ahern <dsahern@gmail.com>
Subject: [PATCH net-next 0/2] net: vrf: Support for local traffic with sockets bound to enslaved devices
Date: Fri, 11 Aug 2017 17:11:13 -0700
Message-ID: <1502496675-13349-1-git-send-email-dsahern@gmail.com>
Cc: David Ahern <dsahern@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f67.google.com ([74.125.83.67]:32868 "EHLO
        mail-pg0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751863AbdHLALV (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 11 Aug 2017 20:11:21 -0400
Received: by mail-pg0-f67.google.com with SMTP id u185so4170116pgb.0
        for <netdev@vger.kernel.org>; Fri, 11 Aug 2017 17:11:21 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This set gets local traffic working for sockets bound to enslaved
devices. The local rtable and rt6_info added in June 2016 to get
local traffic in VRFs working is no longer needed and actually
keeps local traffic for sockets bound to an enslaved device from
working. Patch 1 removes them.

Patch 2 adds a fix up for IPv4 IP_PKTINFO to return rt_iif for
packets sent over the VRF device. This is similar to the handling
of loopback.

David Ahern (2):
  net: vrf: Drop local rtable and rt6_info
  net: ipv4: add check for l3slave for index returned in IP_PKTINFO

 drivers/net/vrf.c      | 122 ++++---------------------------------------------
 net/ipv4/ip_sockglue.c |   3 +-
 2 files changed, 10 insertions(+), 115 deletions(-)

-- 
2.1.4
