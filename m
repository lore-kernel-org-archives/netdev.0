From: Pravin B Shelar <pshelar@nicira.com>
Subject: [PATCH net-next 0/6] Tunneling: Tunnel restructuring.
Date: Wed, 13 Mar 2013 15:48:23 -0700
Message-ID: <1363214903-3225-1-git-send-email-pshelar@nicira.com>
Cc: netdev@vger.kernel.org, jesse@nicira.com,
	Pravin B Shelar <pshelar@nicira.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog115.obsmtp.com ([74.125.149.238]:36727 "HELO
	na3sys009aog115.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1755609Ab3CMWtE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Mar 2013 18:49:04 -0400
Received: by mail-da0-f69.google.com with SMTP id p8so1393953dan.4
        for <netdev@vger.kernel.org>; Wed, 13 Mar 2013 15:49:02 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Following patch series restructure GRE and IPIP tunneling code
to make it modular. It adds ip_tunnel module which acts as
generic tunneling layer which has common code.

These patches do not change any functionality. 

Pravin B Shelar (6):
  GRE: Use RTNL for atomic protocol registration.
  GRE: Refactor GRE tunneling code.
  IPIP: Use ip-tunneling code.
  VXLAN: Fix vxlan stats handling.
  VXLAN: Use IP Tunnels tunnel ENC encap API
  tunnels: Use IP Tunnel stats APIs.

 drivers/net/Kconfig      |    1 +
 drivers/net/ppp/pptp.c   |    4 +
 drivers/net/vxlan.c      |  100 +---
 include/net/gre.h        |   51 ++
 include/net/ip_tunnels.h |  169 ++++++
 include/net/ipip.h       |   88 ---
 net/ipv4/Kconfig         |    7 +
 net/ipv4/Makefile        |    1 +
 net/ipv4/af_inet.c       |    1 -
 net/ipv4/gre.c           |   23 +-
 net/ipv4/ip_gre.c        | 1492 ++++++++++------------------------------------
 net/ipv4/ip_tunnel.c     | 1036 ++++++++++++++++++++++++++++++++
 net/ipv4/ip_vti.c        |   42 +--
 net/ipv4/ipip.c          |  745 ++---------------------
 net/ipv4/ipmr.c          |    2 +-
 net/ipv6/Kconfig         |    2 +
 net/ipv6/af_inet6.c      |    1 -
 net/ipv6/ip6_gre.c       |   43 +--
 net/ipv6/ip6_tunnel.c    |    1 +
 net/ipv6/sit.c           |   39 +--
 20 files changed, 1654 insertions(+), 2194 deletions(-)
 create mode 100644 include/net/ip_tunnels.h
 delete mode 100644 include/net/ipip.h
 create mode 100644 net/ipv4/ip_tunnel.c
