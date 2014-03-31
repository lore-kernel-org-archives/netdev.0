From: Phoebe Buckheister <phoebe.buckheister@itwm.fraunhofer.de>
Subject: [PATCH net-next v2] mac802154: fix multiple WPAN handling
Date: Mon, 31 Mar 2014 21:37:44 +0200
Message-ID: <1396294666-14005-1-git-send-email-phoebe.buckheister@itwm.fraunhofer.de>
Cc: linux-zigbee-devel@lists.sourceforge.net, davem@davemloft.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from selenium.quasiparticle.net ([188.40.96.248]:46788 "EHLO
	quasiparticle.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751004AbaCaTh5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 31 Mar 2014 15:37:57 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The current mac802154 stack allows an arbitrary number of WPAN netdevs for any
given PHY, which is not sensible and not supported by all hardware with in-tree
drivers. Also, previous commits have introduced configuration options that
apply to WPAN devices, but were set to apply to the underlying PHY.

This patch set fixes both, allowing only one WPAN device to be up at any given
time, and making WPAN-related settings per-WPAN instead of per-PHY.

---

Changes since v1:
 * fix check for PHY property setter methods. Reported by Alexander Aring

---

Applies on top of 9109e17f7c3ace48629397b44db5ce06bf168644. Fixes a possible
DoS bug and moves some netdev properties in mac802154 to the places they should
have gone from the outset.


Phoebe Buckheister (2):
      mac802154: allow only one WPAN to be up at any given time
      mac802154: make csma/cca parameters per-wpan


 include/linux/nl802154.h        |   2 +-
 include/net/ieee802154_netdev.h |  17 ++++
 net/ieee802154/ieee802154.h     |   2 +-
 net/ieee802154/netlink.c        |   2 +-
 net/ieee802154/nl-mac.c         | 122 +++++++++++++++++++++++-
 net/ieee802154/nl-phy.c         | 200 +---------------------------------------
 net/ieee802154/wpan-class.c     |   6 --
 net/mac802154/ieee802154_dev.c  |  61 +++++++-----
 net/mac802154/mac802154.h       |  10 ++
 net/mac802154/mac_cmd.c         |   3 +
 net/mac802154/wpan.c            |  89 +++++++++++++++++-
 11 files changed, 278 insertions(+), 236 deletions(-)
