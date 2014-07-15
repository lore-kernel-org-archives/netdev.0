From: Pravin B Shelar <pshelar@nicira.com>
Subject: [GIT net-next v2] Open vSwitch
Date: Tue, 15 Jul 2014 10:14:08 -0700
Message-ID: <1405444448-16836-1-git-send-email-pshelar@nicira.com>
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog112.obsmtp.com ([74.125.149.207]:35411 "HELO
	na3sys009aog112.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1756153AbaGOROO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Jul 2014 13:14:14 -0400
Received: by mail-pa0-f54.google.com with SMTP id fa1so4187776pad.41
        for <netdev@vger.kernel.org>; Tue, 15 Jul 2014 10:14:14 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Following patches adds three features to OVS
1. Add fairness to upcall processing.
2. Recirculation and Hash action.
3. Enable Tunnel GSO features.
Rest of patches are bug fixes related to patches from same series.

v2 series changes first patch according to comments from Dave Miller.

The following changes since commit 0854a7f13206d7523abe773235bbe4d13958fc4b:

  Merge branch 'amd811e-cleanups' (2014-07-14 19:14:44 -0700)

are available in the git repository at:


  git://git.kernel.org/pub/scm/linux/kernel/git/pshelar/openvswitch.git net_next_ovs

for you to fetch changes up to 56ea5457d4b83118798bdfb4ce0316aa66f2e7b2:

  openvswitch: Add skb_clone NULL check for the sampling action. (2014-07-15 09:00:18 -0700)

----------------------------------------------------------------
Alex Wang (1):
      openvswitch: Allow each vport to have an array of 'port_id's.

Andy Zhou (6):
      openvswitch: Add hash action
      openvswitch: Add recirc action
      openvswitch: Fix key size computation in key_attr_size()
      openvswitch: Avoid memory corruption in queue_userspace_packet()
      openvswitch: Add skb_clone NULL check in the recirc action.
      openvswitch: Add skb_clone NULL check for the sampling action.

Pravin B Shelar (2):
      openvswitch: Enable tunnel GSO for OVS bridge.
      net: Export xmit_recursion

Simon Horman (2):
      openvswitch: Free skb(s) on recirculation error
      openvswitch: Sample action without side effects

 include/linux/netdev_features.h      |   8 +++
 include/linux/netdevice.h            |   3 +
 include/uapi/linux/openvswitch.h     |  39 ++++++++++--
 net/core/dev.c                       |  10 +--
 net/openvswitch/actions.c            | 119 +++++++++++++++++++++++++++++++----
 net/openvswitch/datapath.c           |  79 ++++++++++++++++-------
 net/openvswitch/datapath.h           |   8 ++-
 net/openvswitch/flow.h               |   2 +
 net/openvswitch/flow_netlink.c       |  43 ++++++++++++-
 net/openvswitch/vport-internal_dev.c |   5 +-
 net/openvswitch/vport.c              | 105 ++++++++++++++++++++++++++++++-
 net/openvswitch/vport.h              |  27 ++++++--
 12 files changed, 396 insertions(+), 52 deletions(-)
