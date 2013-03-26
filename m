From: Pravin B Shelar <pshelar@nicira.com>
Subject: [PATCH v4 net-next 0/5] Tunneling: Tunnel restructuring.
Date: Mon, 25 Mar 2013 17:49:29 -0700
Message-ID: <1364258969-3120-1-git-send-email-pshelar@nicira.com>
Cc: netdev@vger.kernel.org, jesse@nicira.com,
	Pravin B Shelar <pshelar@nicira.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from na6sys009bog022.obsmtp.com ([74.125.150.84]:36045 "HELO
	na6sys009bog022.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1753202Ab3CZAzA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Mar 2013 20:55:00 -0400
Received: by mail-pa0-f72.google.com with SMTP id fa10so3083721pad.3
        for <netdev@vger.kernel.org>; Mon, 25 Mar 2013 17:54:59 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Following patch series restructure GRE and IPIP tunneling code
to make it modular. It adds ip_tunnel module which acts as
generic tunneling layer which has common code.

These patches do not change any functionality.
v3:v4:
 - Fixed compilation error in ipv6.
 - Few coding style fixes.
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
 include/net/ip6_tunnel.h |    1 +
 include/net/ip_tunnels.h |  177 ++++++
 include/net/ipip.h       |   84 ---
 net/ipv4/Kconfig         |    7 +
 net/ipv4/Makefile        |    1 +
 net/ipv4/af_inet.c       |    1 -
 net/ipv4/gre.c           |    5 -
 net/ipv4/ip_gre.c        | 1504 ++++++++++------------------------------------
 net/ipv4/ip_tunnel.c     | 1035 +++++++++++++++++++++++++++++++
 net/ipv4/ip_vti.c        |   42 +--
 net/ipv4/ipip.c          |  748 ++---------------------
 net/ipv4/ipmr.c          |    2 +-
 net/ipv6/Kconfig         |    2 +
 net/ipv6/af_inet6.c      |    1 -
 net/ipv6/ip6_gre.c       |   45 +--
 net/ipv6/ip6_tunnel.c    |    1 +
 net/ipv6/sit.c           |   39 +--
 20 files changed, 1668 insertions(+), 2179 deletions(-)
 create mode 100644 include/net/ip_tunnels.h
 delete mode 100644 include/net/ipip.h
 create mode 100644 net/ipv4/ip_tunnel.c
