From: Jiri Pirko <jpirko@redhat.com>
Subject: [patch net-next-2.6 0/6] mostly bonding cleanups (partial repost)
Date: Sat, 12 Mar 2011 14:14:33 +0100
Message-ID: <1299935679-18135-1-git-send-email-jpirko@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Cc: davem@davemloft.net, shemminger@linux-foundation.org,
	kaber@trash.net, fubar@us.ibm.com, eric.dumazet@gmail.com,
	nicolas.2p.debian@gmail.com, andy@greyhouse.net, xiaosuo@gmail.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:10711 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752324Ab1CLNOu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 12 Mar 2011 08:14:50 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

My original series had 2 more patches. That ones I posponed until I resolve
problems with delivering vlan arps to bond_frame_handler on non-vlan_hw_accel
path.

So for now, there are following patches that are ready to be applied I believe.

Note the dependency on "fcoe: correct checking for bonding" patch that has not
been applied so far on scsi-misc. I believe that maybe this patch could be
applied on net-next instead.

Jiri Pirko (6):
  af_packet: use skb->skb_iif instead of orig_dev->ifindex
  bonding: register slave pointer for rx_handler
  net: get rid of multiple bond-related netdevice->priv_flags
  bonding: wrap slave state work
  bonding: get rid of IFF_SLAVE_INACTIVE netdev->priv_flag
  net: introduce rx_handler results and logic around that

 drivers/net/bonding/bond_3ad.c   |    2 +-
 drivers/net/bonding/bond_main.c  |  102 +++++++++++++++++++-------------------
 drivers/net/bonding/bond_sysfs.c |   14 +----
 drivers/net/bonding/bonding.h    |   60 +++++++++++++----------
 drivers/net/macvlan.c            |   11 ++--
 include/linux/if.h               |   23 +++-----
 include/linux/netdevice.h        |   50 ++++++++++++++++++-
 include/linux/skbuff.h           |    5 +--
 net/bridge/br_input.c            |   25 ++++++----
 net/bridge/br_private.h          |    2 +-
 net/core/dev.c                   |   21 +++++---
 net/core/skbuff.c                |    1 -
 net/packet/af_packet.c           |    4 +-
 13 files changed, 186 insertions(+), 134 deletions(-)

-- 
1.7.4

