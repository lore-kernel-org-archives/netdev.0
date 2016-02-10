From: Antonio Quartulli <a@unstable.cc>
Subject: pull request [net-next]: batman-adv 20160210
Date: Wed, 10 Feb 2016 23:57:06 +0800
Message-ID: <1455119847-5862-1-git-send-email-a@unstable.cc>
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from s2.neomailbox.net ([5.148.176.60]:49099 "EHLO s2.neomailbox.net"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751538AbcBJP7t (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 10 Feb 2016 10:59:49 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello David,

this is another pull request intended for net-next.

Here you have a batch of patches by Sven Eckelmann that
drops our private reference counting implementation and
substitutes it with the kref objects/functions.

Then you have a patch, by Simon Wunderlich, that
makes the broadcast protection window code more generic so
that it can be re-used in the future by other components
with different requirements.

Lastly, Sven is also introducing two lockdep asserts in
functions operating on our TVLV container list, to make
sure that the proper lock is always acquired by the users.

Please pull or let me know of any problem!
Thanks a lot,
	Antonio


The following changes since commit aaa5672052cb0f18a5ab0ab19e9ef71c50e018a8:

  sxgbe: remove unused code (2016-02-10 06:10:17 -0500)

are available in the git repository at:

  git://git.open-mesh.org/linux-merge.git tags/batman-adv-for-davem

for you to fetch changes up to 92dcdf09a139e51b7b043b9443b8fd69de298dff:

  batman-adv: Convert batadv_tt_common_entry to kref (2016-02-10 23:24:06 +0800)

----------------------------------------------------------------
Here you have a batch of patches by Sven Eckelmann that
drops our private reference counting implementation and
substitutes it with the kref objects/functions.

Then you have a patch, by Simon Wunderlich, that
makes the broadcast protection window code more generic so
that it can be re-used in the future by other components
with different requirements.

Lastly, Sven is also introducing two lockdep asserts in
functions operating on our TVLV container list, to make
sure that the proper lock is always acquired by the users.

----------------------------------------------------------------
Simon Wunderlich (1):
      batman-adv: add seqno maximum age and protection start flag parameters

Sven Eckelmann (20):
      batman-adv: Drop reference to netdevice on last reference
      batman-adv: Add lockdep assert for container_list_lock
      batman-adv: Convert batadv_hardif_neigh_node to kref
      batman-adv: Convert batadv_gw_node to kref
      batman-adv: Convert batadv_softif_vlan to kref
      batman-adv: Convert batadv_bla_backbone_gw to kref
      batman-adv: Convert batadv_bla_claim to kref
      batman-adv: Convert batadv_nc_node to kref
      batman-adv: Convert batadv_nc_path to kref
      batman-adv: Convert batadv_dat_entry to kref
      batman-adv: Convert batadv_tvlv_container to kref
      batman-adv: Convert batadv_tvlv_handler to kref
      batman-adv: Convert batadv_tt_orig_list_entry to kref
      batman-adv: Convert batadv_neigh_ifinfo to kref
      batman-adv: Convert batadv_orig_ifinfo to kref
      batman-adv: Convert batadv_neigh_node to kref
      batman-adv: Convert batadv_hard_iface to kref
      batman-adv: Convert batadv_orig_node_vlan to kref
      batman-adv: Convert batadv_orig_node to kref
      batman-adv: Convert batadv_tt_common_entry to kref

 net/batman-adv/bat_iv_ogm.c            |  12 ++--
 net/batman-adv/bridge_loop_avoidance.c |  43 +++++++++---
 net/batman-adv/distributed-arp-table.c |  29 ++++++--
 net/batman-adv/gateway_client.c        |  44 ++++++++----
 net/batman-adv/hard-interface.c        |  25 ++++---
 net/batman-adv/hard-interface.h        |  16 ++---
 net/batman-adv/main.c                  |  50 +++++++++++---
 net/batman-adv/main.h                  |   3 +
 net/batman-adv/multicast.c             |   7 +-
 net/batman-adv/network-coding.c        |  51 +++++++++-----
 net/batman-adv/originator.c            | 122 ++++++++++++++++++++-------------
 net/batman-adv/originator.h            |   4 +-
 net/batman-adv/routing.c               |  26 ++++---
 net/batman-adv/routing.h               |   3 +-
 net/batman-adv/soft-interface.c        |  33 ++++++---
 net/batman-adv/sysfs.c                 |   3 +-
 net/batman-adv/translation-table.c     |  90 +++++++++++++++++-------
 net/batman-adv/types.h                 |  37 +++++-----
 18 files changed, 405 insertions(+), 193 deletions(-)
