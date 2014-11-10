From: Pravin B Shelar <pshelar@nicira.com>
Subject: [GIT net-next] Open vSwitch
Date: Sun,  9 Nov 2014 19:58:59 -0800
Message-ID: <1415591939-1535-1-git-send-email-pshelar@nicira.com>
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog109.obsmtp.com ([74.125.149.201]:46367 "HELO
	na3sys009aog109.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1752073AbaKJD7D (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 9 Nov 2014 22:59:03 -0500
Received: by mail-pd0-f174.google.com with SMTP id p10so6930539pdj.5
        for <netdev@vger.kernel.org>; Sun, 09 Nov 2014 19:59:01 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Following batch of patches brings feature parity between upstream
ovs and out of tree ovs module.

Two features are added, first adds support to export egress
tunnel information for a packet. This is used to improve
visibility in network traffic. Second feature allows userspace
vswitchd process to probe ovs module features. Other patches
are optimization and code cleanup.

----------------------------------------------------------------
The following changes since commit c0560b9c523341516eabf0f3b51832256caa7bbb:

  dccp: Convert DCCP_WARN to net_warn_ratelimited (2014-11-08 21:22:54 -0500)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/pshelar/openvswitch.git net_next_ovs

for you to fetch changes up to 05da5898a96c05e32aa9850c9cd89eef29471b13:

  openvswitch: Add support for OVS_FLOW_ATTR_PROBE. (2014-11-09 18:58:44 -0800)

----------------------------------------------------------------
Jarno Rajahalme (1):
      openvswitch: Add support for OVS_FLOW_ATTR_PROBE.

Pravin B Shelar (3):
      openvswitch: Export symbols as GPL symbols.
      openvswitch: Optimize recirc action.
      openvswitch: Remove redundant key ref from upcall_info.

Thomas Graf (1):
      openvswitch: Constify various function arguments

Wenyu Zhang (1):
      openvswitch: Extend packet attribute for egress tunnel info

 include/uapi/linux/openvswitch.h |  15 ++
 net/openvswitch/actions.c        | 180 ++++++++++++++------
 net/openvswitch/datapath.c       | 129 ++++++++------
 net/openvswitch/datapath.h       |  22 +--
 net/openvswitch/flow.c           |   8 +-
 net/openvswitch/flow.h           |  71 ++++++--
 net/openvswitch/flow_netlink.c   | 357 +++++++++++++++++++++++----------------
 net/openvswitch/flow_netlink.h   |  13 +-
 net/openvswitch/flow_table.c     |  12 +-
 net/openvswitch/flow_table.h     |   8 +-
 net/openvswitch/vport-geneve.c   |  23 ++-
 net/openvswitch/vport-gre.c      |  12 +-
 net/openvswitch/vport-netdev.c   |   2 +-
 net/openvswitch/vport-vxlan.c    |  24 ++-
 net/openvswitch/vport.c          |  81 +++++++--
 net/openvswitch/vport.h          |  20 ++-
 16 files changed, 664 insertions(+), 313 deletions(-)
