From: Pravin B Shelar <pshelar@nicira.com>
Subject: [GIT net-next v6] Open vSwitch
Date: Sun, 20 Jul 2014 23:16:53 -0700
Message-ID: <1405923413-1855-1-git-send-email-pshelar@nicira.com>
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog112.obsmtp.com ([74.125.149.207]:60046 "HELO
	na3sys009aog112.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1752461AbaGUGQz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Jul 2014 02:16:55 -0400
Received: by mail-pa0-f54.google.com with SMTP id fa1so9106910pad.41
        for <netdev@vger.kernel.org>; Sun, 20 Jul 2014 23:16:54 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Following patches adds three features to OVS
1. Add fairness to upcall processing.
2. Recirculation and Hash action.
3. Enable Tunnel GSO features.
Rest of patches are bug fixes related to patches from same series.

v2 series changes first patch according to comment from Dave Miller.
v3 series changes first patch according to comment from Nikolay Aleksandrov.
v4 series chage recirc patch commit msg.
v5 series resolve conflict with net-next, updated recic action patch.
v6 series sends all patches.
 
----------------------------------------------------------------

The following changes since commit da388973d4a15e71cada1219d625b5393c90e5ae:

  iw_cxgb4: fix for 64-bit integer division (2014-07-17 16:52:08 -0700)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/pshelar/openvswitch.git net_next_ovs

for you to fetch changes up to 21ee5f99279caddcb24f0df33fbcac05e88dbbff:

  openvswitch: Add skb_clone NULL check for the sampling action. (2014-07-17 20:36:54 -0700)

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
 net/openvswitch/datapath.c           |  81 +++++++++++++++++-------
 net/openvswitch/datapath.h           |   8 ++-
 net/openvswitch/flow.h               |   2 +
 net/openvswitch/flow_netlink.c       |  43 ++++++++++++-
 net/openvswitch/vport-internal_dev.c |   5 +-
 net/openvswitch/vport.c              |  99 ++++++++++++++++++++++++++++-
 net/openvswitch/vport.h              |  27 ++++++--
 12 files changed, 391 insertions(+), 53 deletions(-)
