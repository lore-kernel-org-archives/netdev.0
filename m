From: David Ahern <dsa@cumulusnetworks.com>
Subject: [PATCH net-next 0/3] net: vrf: Fix ipv6 source address selection
Date: Thu, 16 Jun 2016 16:24:23 -0700
Message-ID: <1466119466-3144-1-git-send-email-dsa@cumulusnetworks.com>
Cc: David Ahern <dsa@cumulusnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f169.google.com ([209.85.192.169]:34545 "EHLO
	mail-pf0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752063AbcFPXYd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Jun 2016 19:24:33 -0400
Received: by mail-pf0-f169.google.com with SMTP id h14so9150272pfe.1
        for <netdev@vger.kernel.org>; Thu, 16 Jun 2016 16:24:33 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

IPv6 address selection is currently messed up for several use cases such
as unnumbered deployments with global addresses on the VRF device and none
on the enslaved devices.

Update the source address selection to consider the real output route as
opposed to the VRF route that sends packets to the VRF device first (ie.,
implement get_saddr6 similar to the IPv4 method) and update the IPv6
address selection to consider L3 domains and preference for addresses on
the VRF device).

David Ahern (3):
  net: ipv6: Move ip6_route_get_saddr to inline
  net: vrf: Implement get_saddr for IPv6
  net: ipv6: Address selection needs to consider L3 domains

 drivers/net/vrf.c       | 41 +++++++++++++++++++++++++++++++++++++++++
 include/net/ip6_route.h | 21 ++++++++++++++++++---
 include/net/l3mdev.h    | 42 ++++++++++++++++++++++++++++++++++++++++++
 net/ipv6/addrconf.c     | 48 ++++++++++++++++++++++++++++++++++++++++++++++++
 net/ipv6/ip6_output.c   | 12 ++++++++++--
 net/ipv6/route.c        | 17 -----------------
 net/l3mdev/l3mdev.c     | 24 ++++++++++++++++++++++++
 7 files changed, 183 insertions(+), 22 deletions(-)

-- 
2.1.4
