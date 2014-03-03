From: Phoebe Buckheister <phoebe.buckheister@itwm.fraunhofer.de>
Subject: [PATCH net-next v3 0/4] ieee802154: clean up header handling
Date: Mon,  3 Mar 2014 23:07:51 +0100
Message-ID: <1393884475-20927-1-git-send-email-phoebe.buckheister@itwm.fraunhofer.de>
Cc: linux-zigbee-devel@lists.sourceforge.net, davem@davemloft.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from selenium.quasiparticle.net ([188.40.96.248]:40228 "EHLO
	quasiparticle.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755068AbaCCWH6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 Mar 2014 17:07:58 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series of patches cleans up handling of 802.15.4 headers in ieee802154 and
mac802154. Particularly, it introduces new functions to read and modify headers
and removes the address fields in the skb cb block in favour of these
functions. This set also fixes a bug that caused parts of an 802.15.4 header to
be delivered to dgram sockets in userspace due to misparsed headers, and moves
mac frame sequence number generation from upper layers into the netdev that
actually handles them.

---

Changes since v2:
 * Formatting
Changes since v1:
 * Tested-by: Alexander Aring <alex.aring@gmail.com>
 * trivial checkpatch issues. The "/*\n" in a copyright header was kept for
   consistency, some macro definition lines over 80 characters for readability


Phoebe Buckheister (4):
      ieee802154: add generic header handling routines
      mac802154: use new header ops in wpan devices
      ieee802154: remove addresses from mac_cb
      ieee802154: remove seq member of mac_cb


 include/net/ieee802154.h        |  15 ++
 include/net/ieee802154_netdev.h |  52 ++++--
 include/net/mac802154.h         |   1 +
 net/ieee802154/6lowpan_rtnl.c   |  13 +-
 net/ieee802154/Makefile         |   3 +-
 net/ieee802154/dgram.c          |   6 +-
 net/ieee802154/header_ops.c     | 328 ++++++++++++++++++++++++++++++++++++++
 net/ieee802154/reassembly.c     |   5 +-
 net/mac802154/wpan.c            | 343 +++++++++++-----------------------------
 9 files changed, 495 insertions(+), 271 deletions(-)
