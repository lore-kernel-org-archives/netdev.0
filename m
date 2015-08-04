From: Pravin B Shelar <pshelar@nicira.com>
Subject: [PATCH net-next v3 0/3] GRE: Use flow based tunneling for OVS GRE vport.
Date: Tue,  4 Aug 2015 16:22:06 -0700
Message-ID: <1438730526-3081-1-git-send-email-pshelar@nicira.com>
Cc: Pravin B Shelar <pshelar@nicira.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f44.google.com ([209.85.220.44]:33685 "EHLO
	mail-pa0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752901AbbHDXWM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Aug 2015 19:22:12 -0400
Received: by padck2 with SMTP id ck2so19658224pad.0
        for <netdev@vger.kernel.org>; Tue, 04 Aug 2015 16:22:11 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Following patches make use of new flow based tunneling
API from kernel. This allows us to directly use netdev
based GRE tunnel implementation. While doing so I have
removed GRE demux API which were targeted for OVS. Most
of GRE protocol code is now consolidated in ip_gre module.

v2-v3:
Add API to create GRE flow based device.
---

Pravin B Shelar (3):
  openvswitch: Move tunnel destroy function to oppenvswitch module.
  openvswitch: Use regular GRE net_device instead of vport
  gre: Remove support for sharing GRE protocol hook.

 include/net/gre.h              |  91 +--------
 include/net/ip_tunnels.h       |   7 +-
 net/ipv4/gre_demux.c           | 235 +----------------------
 net/ipv4/ip_gre.c              | 417 +++++++++++++++++++++++++++++++++++++++--
 net/ipv4/ip_tunnel.c           |  30 ++-
 net/ipv4/ipip.c                |   2 +-
 net/ipv6/sit.c                 |   2 +-
 net/openvswitch/Kconfig        |   1 -
 net/openvswitch/vport-gre.c    | 237 +++--------------------
 net/openvswitch/vport-netdev.c |  16 ++
 net/openvswitch/vport-netdev.h |   1 +
 net/openvswitch/vport-vxlan.c  |  17 +-
 12 files changed, 476 insertions(+), 580 deletions(-)

-- 
1.8.3.1
