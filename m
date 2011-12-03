From: Jesse Gross <jesse@nicira.com>
Subject: [GIT PULL v3] Open vSwitch
Date: Sat,  3 Dec 2011 10:38:45 -0800
Message-ID: <1322937531-8071-1-git-send-email-jesse@nicira.com>
Cc: netdev@vger.kernel.org, dev@openvswitch.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-iy0-f174.google.com ([209.85.210.174]:36442 "EHLO
	mail-iy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753971Ab1LCSi5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 3 Dec 2011 13:38:57 -0500
Received: by iage36 with SMTP id e36so6004137iag.19
        for <netdev@vger.kernel.org>; Sat, 03 Dec 2011 10:38:57 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series of patches proposes the Open vSwitch kernel components for
upstream.  Open vSwitch has existed as a separate project for several
years and we now believe it to be mature enough for inclusion.  The
actual functionality is described more fully in the commit that adds
the kernel code.

The following changes since commit 340e8dc1fb4032b6c8334c9bff20b2aec42ecfd8:

  atm: clip: Remove code commented out since eternity. (2011-12-02 14:27:11 -0500)

are available in the git repository at:
  git://git.kernel.org/pub/scm/linux/kernel/git/jesse/openvswitch.git for-upstream

Jesse Gross (3):
      genetlink: Add rcu_dereference_genl and genl_dereference.
      ipv6: Add fragment reporting to ipv6_skip_exthdr().
      net: Add Open vSwitch kernel components.

Pravin B Shelar (3):
      genetlink: Add genl_notify()
      genetlink: Add lockdep_genl_is_held().
      vlan: Move vlan_set_encap_proto() to vlan header file

 Documentation/networking/00-INDEX        |    2 +
 Documentation/networking/openvswitch.txt |  195 +++
 MAINTAINERS                              |    8 +
 include/linux/genetlink.h                |   24 +
 include/linux/if_vlan.h                  |   34 +
 include/linux/openvswitch.h              |  452 +++++++
 include/net/genetlink.h                  |    2 +
 include/net/ipv6.h                       |    2 +-
 net/8021q/vlan_core.c                    |   33 -
 net/Kconfig                              |    1 +
 net/Makefile                             |    1 +
 net/bridge/br_multicast.c                |    3 +-
 net/bridge/netfilter/ebt_ip6.c           |    3 +-
 net/bridge/netfilter/ebt_log.c           |    3 +-
 net/ipv6/exthdrs_core.c                  |   11 +-
 net/ipv6/icmp.c                          |    7 +-
 net/ipv6/ip6_input.c                     |    3 +-
 net/ipv6/ip6_output.c                    |    3 +-
 net/ipv6/netfilter/ip6t_REJECT.c         |    3 +-
 net/netfilter/ipset/ip_set_getport.c     |    4 +-
 net/netfilter/xt_AUDIT.c                 |    3 +-
 net/netfilter/xt_TCPMSS.c                |    3 +-
 net/netfilter/xt_TCPOPTSTRIP.c           |    3 +-
 net/netfilter/xt_hashlimit.c             |    3 +-
 net/netfilter/xt_socket.c                |    4 +-
 net/netlink/genetlink.c                  |   21 +
 net/openvswitch/Kconfig                  |   28 +
 net/openvswitch/Makefile                 |   14 +
 net/openvswitch/actions.c                |  415 +++++++
 net/openvswitch/datapath.c               | 1912 ++++++++++++++++++++++++++++++
 net/openvswitch/datapath.h               |  125 ++
 net/openvswitch/dp_notify.c              |   66 +
 net/openvswitch/flow.c                   | 1346 +++++++++++++++++++++
 net/openvswitch/flow.h                   |  199 ++++
 net/openvswitch/vport-internal_dev.c     |  241 ++++
 net/openvswitch/vport-internal_dev.h     |   28 +
 net/openvswitch/vport-netdev.c           |  198 +++
 net/openvswitch/vport-netdev.h           |   42 +
 net/openvswitch/vport.c                  |  396 ++++++
 net/openvswitch/vport.h                  |  205 ++++
 security/lsm_audit.c                     |    3 +-
 security/selinux/hooks.c                 |    3 +-
 42 files changed, 6000 insertions(+), 52 deletions(-)
 create mode 100644 Documentation/networking/openvswitch.txt
 create mode 100644 include/linux/openvswitch.h
 create mode 100644 net/openvswitch/Kconfig
 create mode 100644 net/openvswitch/Makefile
 create mode 100644 net/openvswitch/actions.c
 create mode 100644 net/openvswitch/datapath.c
 create mode 100644 net/openvswitch/datapath.h
 create mode 100644 net/openvswitch/dp_notify.c
 create mode 100644 net/openvswitch/flow.c
 create mode 100644 net/openvswitch/flow.h
 create mode 100644 net/openvswitch/vport-internal_dev.c
 create mode 100644 net/openvswitch/vport-internal_dev.h
 create mode 100644 net/openvswitch/vport-netdev.c
 create mode 100644 net/openvswitch/vport-netdev.h
 create mode 100644 net/openvswitch/vport.c
 create mode 100644 net/openvswitch/vport.h
