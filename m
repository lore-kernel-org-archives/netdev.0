From: Phoebe Buckheister <phoebe.buckheister@itwm.fraunhofer.de>
Subject: [PATCH net-next 0/4] ieee802154: clean up header handling
Date: Mon,  3 Mar 2014 13:59:03 +0100
Message-ID: <1393851547-27876-1-git-send-email-phoebe.buckheister@itwm.fraunhofer.de>
Cc: linux-zigbee-devel@lists.sourceforge.net, davem@davemloft.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailgw1.uni-kl.de ([131.246.120.220]:59635 "EHLO
	mailgw1.uni-kl.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753697AbaCCM7Y (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 Mar 2014 07:59:24 -0500
Received: from itwm2.itwm.fhg.de (itwm2.itwm.fhg.de [131.246.191.3])
	by mailgw1.uni-kl.de (8.14.3/8.14.3/Debian-9.4) with ESMTP id s23CxLxn019484
	(version=TLSv1/SSLv3 cipher=EDH-RSA-DES-CBC3-SHA bits=168 verify=NOT)
	for <netdev@vger.kernel.org>; Mon, 3 Mar 2014 13:59:22 +0100
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series of patches cleans up handling of 802.15.4 headers in ieee802154 and
mac802154. Particularly, it introduces new functions to read and modify headers
and removes the address fields in the skb cb block in favour of these
functions. This set also fixes a bug that caused parts of an 802.15.4 header to
be delivered to dgram sockets in userspace due to misparsed headers, and moves
mac frame sequence number generation from upper layers into the netdev that
actually handles them.

--

Phoebe Buckheister (4):
      ieee802154: add generic header handling routines
      mac802154: use new header ops in wpan devices
      ieee802154: remove addresses from mac_cb
      ieee802154: remove seq member of mac_cb

 include/net/ieee802154.h        |   15 ++
 include/net/ieee802154_netdev.h |   52 +++++-
 include/net/mac802154.h         |    1 +
 net/ieee802154/6lowpan_rtnl.c   |   13 +-
 net/ieee802154/Makefile         |    3 +-
 net/ieee802154/dgram.c          |    6 +-
 net/ieee802154/header_ops.c     |  331 +++++++++++++++++++++++++++++++++++++
 net/ieee802154/reassembly.c     |    5 +-
 net/mac802154/wpan.c            |  344 +++++++++++----------------------------
 9 files changed, 499 insertions(+), 271 deletions(-)
