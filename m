From: Pravin B Shelar <pshelar@nicira.com>
Subject: [PATCH v2 net-next 0/5] Tunneling: Tunnel restructuring.
Date: Mon, 18 Mar 2013 11:13:21 -0700
Message-ID: <1363630401-1640-1-git-send-email-pshelar@nicira.com>
Cc: netdev@vger.kernel.org, jesse@nicira.com,
	Pravin B Shelar <pshelar@nicira.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog117.obsmtp.com ([74.125.149.242]:45721 "HELO
	na3sys009aog117.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1753439Ab3CRSOK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Mar 2013 14:14:10 -0400
Received: by mail-da0-f72.google.com with SMTP id q27so3141859daj.3
        for <netdev@vger.kernel.org>; Mon, 18 Mar 2013 11:14:09 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Following patch series restructure GRE and IPIP tunneling code
to make it modular. It adds ip_tunnel module which acts as
generic tunneling layer which has common code.

These patches do not change any functionality. I dropped patch
to convert gre_proto_lock to rtnl lock according t comment from
Stephen Hemminger.

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
 net/ipv4/ip_gre.c        | 1501 ++++++++++------------------------------------
 net/ipv4/ip_tunnel.c     | 1035 ++++++++++++++++++++++++++++++++
 net/ipv4/ip_vti.c        |   42 +--
 net/ipv4/ipip.c          |  749 ++---------------------
 net/ipv4/ipmr.c          |    2 +-
 net/ipv6/Kconfig         |    2 +
 net/ipv6/af_inet6.c      |    1 -
 net/ipv6/ip6_gre.c       |   43 +--
 net/ipv6/ip6_tunnel.c    |    1 +
 net/ipv6/sit.c           |   39 +--
 19 files changed, 1654 insertions(+), 2184 deletions(-)
 create mode 100644 include/net/ip_tunnels.h
 delete mode 100644 include/net/ipip.h
 create mode 100644 net/ipv4/ip_tunnel.c
