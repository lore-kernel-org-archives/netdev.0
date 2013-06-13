From: Pravin B Shelar <pshelar@nicira.com>
Subject: [PATCH net-next 00/12] openvswitch: gre tunneling support.
Date: Thu, 13 Jun 2013 11:24:02 -0700
Message-ID: <1371147842-9088-1-git-send-email-pshelar@nicira.com>
Cc: Pravin B Shelar <pshelar@nicira.com>
To: netdev@vger.kernel.org, dev@openvswitch.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog113.obsmtp.com ([74.125.149.209]:34110 "HELO
	na3sys009aog113.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1756774Ab3FMSYI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Jun 2013 14:24:08 -0400
Received: by mail-pb0-f48.google.com with SMTP id ma3so5162155pbc.21
        for <netdev@vger.kernel.org>; Thu, 13 Jun 2013 11:24:08 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Following patch series adds support for gre tunneling.
First six patches extend kernel gre and ip_tunnel modules
api so that there is more code sharing between gre modules
and ovs. Rest of patches adds ovs tunneling infrastructre
and gre protocol vport.

This series depends on "openvswitch tunneling preparation" patches.

Pravin B Shelar (12):
  gre: Simplify gre protocol registration locking.
  gre: Allow multiple protocol listener for gre protocol.
  gre: export gre_build_header() function.
  gre: export gre_handle_offloads() function.
  ip_tunnels: extend iptunnel_xmit()
  ip_tunnel: push generic protocol handling to ip_tunnel module.
  ip_tunnel: Add dont fragment flag.
  openvswitch: Copy individual actions.
  openvswitch: Add tunneling interface.
  openvswitch: Expand action buffer size.
  openvswitch: Optimize flow key match for non tunnel flows.
  openvswitch: Add gre tunnel support.

 drivers/net/vxlan.c                  |   32 +---
 include/net/gre.h                    |   27 +++
 include/net/ip_tunnels.h             |   28 ++-
 include/uapi/linux/openvswitch.h     |   19 ++
 net/ipv4/Makefile                    |    2 +-
 net/ipv4/gre.c                       |  325 ++++++++++++++++++++++++++++---
 net/ipv4/ip_gre.c                    |  247 +++---------------------
 net/ipv4/ip_tunnel.c                 |   68 ++-----
 net/ipv4/ip_tunnel_core.c            |  121 ++++++++++++
 net/ipv4/ipip.c                      |    6 +-
 net/ipv6/sit.c                       |   44 ++---
 net/openvswitch/Makefile             |    3 +-
 net/openvswitch/actions.c            |    4 +
 net/openvswitch/datapath.c           |  356 ++++++++++++++++++++++++++++------
 net/openvswitch/datapath.h           |    4 +
 net/openvswitch/flow.c               |  188 ++++++++++++++++--
 net/openvswitch/flow.h               |   44 ++++-
 net/openvswitch/vport-gre.c          |  278 ++++++++++++++++++++++++++
 net/openvswitch/vport-internal_dev.c |    2 +-
 net/openvswitch/vport-netdev.c       |    2 +-
 net/openvswitch/vport.c              |   20 ++-
 net/openvswitch/vport.h              |   10 +-
 22 files changed, 1372 insertions(+), 458 deletions(-)
 create mode 100644 net/ipv4/ip_tunnel_core.c
 create mode 100644 net/openvswitch/vport-gre.c
