From: David Ahern <dsa@cumulusnetworks.com>
Subject: [PATCH net-next 0/5] net: Add saddr op to l3mdev and vrf
Date: Thu,  1 Oct 2015 08:27:22 -0700
Message-ID: <1443713247-11230-1-git-send-email-dsa@cumulusnetworks.com>
Cc: dsahern@gmail.com, David Ahern <dsa@cumulusnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f54.google.com ([209.85.220.54]:36083 "EHLO
	mail-pa0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756403AbbJAP1f (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 1 Oct 2015 11:27:35 -0400
Received: by pablk4 with SMTP id lk4so77033364pab.3
        for <netdev@vger.kernel.org>; Thu, 01 Oct 2015 08:27:35 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

First 2 patches are re-sends of patches that got lost in the ethosphere
Tuesday; they were part of the first round of l3mdev conversions.
Next 3 handle the source address lookup for raw and datagram sockets
bound to a VRF device.

The conversion to the get_saddr op also fixes locally originated TCP
packets showing up at the VRF device. The use of the FLOWI_FLAG_L3MDEV_SRC
flag in ip_route_connect_init was causing locally generated packets
to skip the VRF device.

David Ahern (5):
  net: Rename FLOWI_FLAG_VRFSRC to FLOWI_FLAG_L3MDEV_SRC
  net: Add netif_is_l3_slave
  net: Refactor path selection in __ip_route_output_key
  net: Add source address lookup op for VRF
  net: Add l3mdev saddr lookup to raw_sendmsg

 drivers/net/vrf.c         | 47 ++++++++++++++++++++++++++++++++++++++++-------
 include/linux/netdevice.h |  7 +++++++
 include/net/flow.h        |  2 +-
 include/net/ip_fib.h      |  2 ++
 include/net/l3mdev.h      | 27 +++++++++++++++++++++++++++
 include/net/route.h       |  7 ++++---
 net/ipv4/fib_semantics.c  | 18 ++++++++++++++++++
 net/ipv4/raw.c            |  8 ++++++--
 net/ipv4/route.c          | 13 +------------
 net/ipv4/udp.c            | 22 +++-------------------
 net/l3mdev/l3mdev.c       |  8 ++++----
 11 files changed, 113 insertions(+), 48 deletions(-)

-- 
1.9.1
