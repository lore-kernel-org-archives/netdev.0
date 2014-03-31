From: Phoebe Buckheister <phoebe.buckheister@itwm.fraunhofer.de>
Subject: mac802154: make multiple WPAN handling sensible
Date: Mon, 31 Mar 2014 15:17:51 +0200
Message-ID: <1396271873-10300-1-git-send-email-phoebe.buckheister@itwm.fraunhofer.de>
Cc: linux-zigbee-devel@lists.sourceforge.net, davem@davemloft.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailgw1.uni-kl.de ([131.246.120.220]:54659 "EHLO
	mailgw1.uni-kl.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754610AbaCaNbQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 31 Mar 2014 09:31:16 -0400
Received: from itwm2.itwm.fhg.de (itwm2.itwm.fhg.de [131.246.191.3])
	by mailgw1.uni-kl.de (8.14.3/8.14.3/Debian-9.4) with ESMTP id s2VDVELR017068
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NOT)
	for <netdev@vger.kernel.org>; Mon, 31 Mar 2014 15:31:14 +0200
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The current mac802154 stack allows an arbitrary number of WPAN netdevs for any
given PHY, which is not sensible and not supported by all hardware with in-tree
drivers. Also, previous commits have introduced configuration options that
apply to WPAN devices, but were set to apply to the underlying PHY.

This patch set fixes both, allowing only one WPAN device to be up at any given
time, and making WPAN-related settings per-WPAN instead of per-PHY.

---

Phoebe Buckheister (2):
      mac802154: allow only one WPAN to be up at any given time
      mac802154: make csma/cca parameters per-wpan


 include/linux/nl802154.h        |    2 +-
 include/net/ieee802154_netdev.h |   17 ++++
 net/ieee802154/ieee802154.h     |    2 +-
 net/ieee802154/netlink.c        |    2 +-
 net/ieee802154/nl-mac.c         |  122 +++++++++++++++++++++++-
 net/ieee802154/nl-phy.c         |  200 +--------------------------------------
 net/ieee802154/wpan-class.c     |    6 --
 net/mac802154/ieee802154_dev.c  |   25 +++++
 net/mac802154/mac802154.h       |   10 ++
 net/mac802154/mac_cmd.c         |    3 +
 net/mac802154/wpan.c            |   89 ++++++++++++++++-
 11 files changed, 266 insertions(+), 212 deletions(-)
