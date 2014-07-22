From: Pravin B Shelar <pshelar@nicira.com>
Subject: [GIT net-next v8] Open vSwitch
Date: Tue, 22 Jul 2014 11:34:06 -0700
Message-ID: <1406054046-1613-1-git-send-email-pshelar@nicira.com>
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from na6sys009bog029.obsmtp.com ([74.125.150.103]:44230 "HELO
	na6sys009bog029.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1751392AbaGVSj4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Jul 2014 14:39:56 -0400
Received: by mail-pa0-f43.google.com with SMTP id lf10so70112pab.16
        for <netdev@vger.kernel.org>; Tue, 22 Jul 2014 11:39:54 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Following patches adds three features to OVS
1. Add fairness to upcall processing.
2. Hash action.
3. Enable Tunnel GSO features.
Rest of patches are bug fixes related to patches from same series.

v2 series changes first patch according to comment from Dave Miller.
v3 series changes first patch according to comment from Nikolay Aleksandrov.
v4 series update recirc patch commit msg.
v5 series resolve conflict with net-next, updated recic action patch.
v6 series sends all patches.
v7 series drop recirc patches.
v8 series checkpatch fix 
----------------------------------------------------------------

The following changes since commit 8fd90bb889635fa1e7f80a3950948cc2e74c1446:

  Merge git://git.kernel.org/pub/scm/linux/kernel/git/davem/net (2014-07-22 00:44:59 -0700)

are available in the git repository at:


  git://git.kernel.org/pub/scm/linux/kernel/git/pshelar/openvswitch.git net_next_ovs

for you to fetch changes up to bc5dd8ec98f2020778f02b53ab94f042a6eefc45:

  openvswitch: Add skb_clone NULL check for the sampling action. (2014-07-22 09:42:00 -0700)

----------------------------------------------------------------
Alex Wang (1):
      openvswitch: Allow each vport to have an array of 'port_id's.

Andy Zhou (3):
      openvswitch: Add hash action
      openvswitch: Avoid memory corruption in queue_userspace_packet()
      openvswitch: Add skb_clone NULL check for the sampling action.

Pravin B Shelar (1):
      openvswitch: Enable tunnel GSO for OVS bridge.

Simon Horman (1):
      openvswitch: Sample action without side effects

 include/linux/netdev_features.h      |   8 +++
 include/uapi/linux/openvswitch.h     |  37 +++++++++++--
 net/openvswitch/actions.c            |  69 ++++++++++++++++++++----
 net/openvswitch/datapath.c           |  26 ++++++---
 net/openvswitch/flow.h               |   1 +
 net/openvswitch/flow_netlink.c       |  27 +++++++++-
 net/openvswitch/vport-internal_dev.c |   5 +-
 net/openvswitch/vport.c              | 101 ++++++++++++++++++++++++++++++++++-
 net/openvswitch/vport.h              |  27 ++++++++--
 9 files changed, 271 insertions(+), 30 deletions(-)
