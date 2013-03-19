From: Pravin B Shelar <pshelar@nicira.com>
Subject: [PATCH v3 net-next 0/5] Tunneling: Tunnel restructuring.
Date: Tue, 19 Mar 2013 01:10:10 -0700
Message-ID: <1363680610-1719-1-git-send-email-pshelar@nicira.com>
Cc: netdev@vger.kernel.org, jesse@nicira.com,
	Pravin B Shelar <pshelar@nicira.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog129.obsmtp.com ([74.125.149.142]:44767 "HELO
	na3sys009aog129.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S933194Ab3CSIKa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Mar 2013 04:10:30 -0400
Received: by mail-da0-f72.google.com with SMTP id q27so273952daj.3
        for <netdev@vger.kernel.org>; Tue, 19 Mar 2013 01:10:29 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Following patch series restructure GRE and IPIP tunneling code
to make it modular. It adds ip_tunnel module which acts as
generic tunneling layer which has common code.

These patches do not change any functionality.

v2-v3:
 - Use GPL exports for all export symbols.
 - Set default config NET_IP_TUNNEL to m.
v1-v2:
 - Dropped patch to convert gre_proto_lock to rtnl lock.

Pravin B Shelar (5):
  GRE: Refactor GRE tunneling code.
  IPIP: Use ip-tunneling code.
  VXLAN: Fix vxlan stats handling.
  VXLAN: Use IP Tunnels tunnel ENC encap API
  Tunneling: use IP Tunnel stats APIs.

 drivers/net/Kconfig      |    1 +
 drivers/net/vxlan.c      |  100 +---
 include/net/gre.h        |   51 ++
 include/net/ip_tunnels.h |  169 ++++++
 include/net/ipip.h       |   88 ---
 net/ipv4/Kconfig         |    7 +
 net/ipv4/Makefile        |    1 +
 net/ipv4/af_inet.c       |    1 -
 net/ipv4/gre.c           |    5 -
 net/ipv4/ip_gre.c        | 1503 ++++++++++------------------------------------
 net/ipv4/ip_tunnel.c     | 1035 +++++++++++++++++++++++++++++++
 net/ipv4/ip_vti.c        |   42 +--
 net/ipv4/ipip.c          |  749 ++---------------------
 net/ipv4/ipmr.c          |    2 +-
 net/ipv6/Kconfig         |    2 +
 net/ipv6/af_inet6.c      |    1 -
 net/ipv6/ip6_gre.c       |   43 +--
 net/ipv6/ip6_tunnel.c    |    1 +
 net/ipv6/sit.c           |   39 +--
 19 files changed, 1654 insertions(+), 2186 deletions(-)
 create mode 100644 include/net/ip_tunnels.h
 delete mode 100644 include/net/ipip.h
 create mode 100644 net/ipv4/ip_tunnel.c
