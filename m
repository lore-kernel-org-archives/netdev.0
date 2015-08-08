From: Pravin B Shelar <pshelar@nicira.com>
Subject: [PATCH net-next v5 0/4] GRE: Use flow based tunneling for OVS GRE vport.
Date: Fri,  7 Aug 2015 23:49:50 -0700
Message-ID: <1439016590-15486-1-git-send-email-pshelar@nicira.com>
Cc: Pravin B Shelar <pshelar@nicira.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f53.google.com ([209.85.220.53]:33346 "EHLO
	mail-pa0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752509AbbHJDqU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 9 Aug 2015 23:46:20 -0400
Received: by pabyb7 with SMTP id yb7so96634803pab.0
        for <netdev@vger.kernel.org>; Sun, 09 Aug 2015 20:46:20 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Following patches make use of new Using GRE tunnel meta data
collection feature. This allows us to directly use netdev
based GRE tunnel implementation. While doing so I have
removed GRE demux API which were targeted for OVS. Most
of GRE protocol code is now consolidated in ip_gre module.

v5-v4:
Fixed Kconfig dependency for vport-gre module.

v3-v4:
Added interface to ip-gre device to enable meta data collection.
While doing this I split second patch into two patches.

v2-v3:
Add API to create GRE flow based device.
---

Pravin B Shelar (4):
  openvswitch: Move tunnel destroy function to oppenvswitch module.
  ip_gre: Add support to collect tunnel metadata.
  openvswitch: Use regular GRE net_device instead of vport
  gre: Remove support for sharing GRE protocol hook.

 include/net/gre.h              |  92 +--------
 include/net/ip_tunnels.h       |   7 +-
 include/uapi/linux/if_tunnel.h |   1 +
 net/ipv4/gre_demux.c           | 235 +---------------------
 net/ipv4/ip_gre.c              | 446 ++++++++++++++++++++++++++++++++++++++---
 net/ipv4/ip_tunnel.c           |  37 +++-
 net/ipv4/ipip.c                |   2 +-
 net/ipv6/sit.c                 |   2 +-
 net/openvswitch/Kconfig        |   2 +-
 net/openvswitch/vport-gre.c    | 237 ++--------------------
 net/openvswitch/vport-netdev.c |  21 +-
 net/openvswitch/vport-netdev.h |   2 +-
 net/openvswitch/vport-vxlan.c  |  17 +-
 13 files changed, 503 insertions(+), 598 deletions(-)

-- 
1.8.3.1
