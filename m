From: Pravin B Shelar <pshelar@nicira.com>
Subject: [GIT net-next] Open vSwitch
Date: Sun, 13 Jul 2014 17:12:43 -0700
Message-ID: <1405296763-3619-1-git-send-email-pshelar@nicira.com>
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog133.obsmtp.com ([74.125.149.82]:49879 "HELO
	na3sys009aog133.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1751022AbaGNAMu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 13 Jul 2014 20:12:50 -0400
Received: by mail-pa0-f52.google.com with SMTP id eu11so4379930pac.39
        for <netdev@vger.kernel.org>; Sun, 13 Jul 2014 17:12:49 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Following patches adds three features to OVS
1. Add fairness to upcall processing.
2. Recirculation and Hash action.
3. Enable Tunnel GSO features.
Rest of patches are bug fixes related to patches from same series.

The following changes since commit 279f64b7a771d84cbdea51ac2f794becfb06bcd4:

  net/hsr: Remove left-over never-true conditional code. (2014-07-11 15:04:40 -0700)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/pshelar/openvswitch.git net_next_ovs

for you to fetch changes up to 3dec4774b6343e5db5d346f1f05c6a883e0069db:

  openvswitch: Add skb_clone NULL check for the sampling action. (2014-07-13 12:02:12 -0700)

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
 net/openvswitch/vport.c              | 102 +++++++++++++++++++++++++++++-
 net/openvswitch/vport.h              |  27 ++++++--
 12 files changed, 393 insertions(+), 52 deletions(-)
