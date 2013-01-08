From: Pravin B Shelar <pshelar@nicira.com>
Subject: [PATCH 0/5] ipv4_tunnels: Modularize ipv4 tunneling.
Date: Mon,  7 Jan 2013 18:31:32 -0800
Message-ID: <1357612292-1682-1-git-send-email-pshelar@nicira.com>
Cc: jesse@nicira.com, Pravin Shelar <pshelar@nicira.com>
To: dev@openvswitch.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog119.obsmtp.com ([74.125.149.246]:48774 "HELO
	na3sys009aog119.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1751515Ab3AHCbP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Jan 2013 21:31:15 -0500
Received: by mail-vc0-f199.google.com with SMTP id p16so31485732vcq.2
        for <netdev@vger.kernel.org>; Mon, 07 Jan 2013 18:31:13 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Pravin Shelar <pshelar@nicira.com>

Following patch series restructure GRE and IPIP tunneling code
to make it modular. It adds ip_tunnel module which acts as
generic tunneling layer which has common code. I have patch
to do same for VXLAN too.

In Addidtion to restructuring it adds demultiplexer for ipgre
protocol, so that linux kernel IPGRE module and OVS gre module
can co-exist.
Last patch adds linux state updates to tunnel device from
lower device.

Pravin Shelar (5):
  GRE: Add segmentation offload for GRE TAP device.
  GRE: Use RTNL for atomic protocol registration.
  GRE: Refactor code GRE code.
  IPIP: Use ip-tunneling code.
  IP_TUNNEL: follow state of lower device

 drivers/net/ppp/pptp.c    |    4 +
 include/linux/if_tunnel.h |    8 -
 include/linux/skbuff.h    |   12 +
 include/net/gre.h         |   57 ++
 include/net/ip_tunnel.h   |  164 +++++
 include/net/ipip.h        |   74 ---
 net/ipv4/Kconfig          |    6 +
 net/ipv4/Makefile         |    1 +
 net/ipv4/af_inet.c        |    2 +-
 net/ipv4/gre.c            |  496 ++++++++++++++-
 net/ipv4/ip_gre.c         | 1569 ++++++++-------------------------------------
 net/ipv4/ip_tunnel.c      | 1171 +++++++++++++++++++++++++++++++++
 net/ipv4/ip_vti.c         |    2 +-
 net/ipv4/ipip.c           |  780 +++--------------------
 net/ipv4/ipmr.c           |    2 +-
 net/ipv4/tcp.c            |    1 +
 net/ipv4/udp.c            |    3 +-
 net/ipv6/af_inet6.c       |    1 -
 net/ipv6/ip6_gre.c        |    1 +
 net/ipv6/ip6_offload.c    |    1 +
 net/ipv6/ip6_tunnel.c     |    1 +
 net/ipv6/sit.c            |    2 +-
 net/ipv6/udp_offload.c    |    3 +-
 23 files changed, 2268 insertions(+), 2093 deletions(-)
 create mode 100644 include/net/ip_tunnel.h
 delete mode 100644 include/net/ipip.h
 create mode 100644 net/ipv4/ip_tunnel.c
