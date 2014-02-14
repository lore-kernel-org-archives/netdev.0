From: Phoebe Buckheister <phoebe.buckheister@itwm.fraunhofer.de>
Subject: [PATCH net-next v2 0/10] ieee802154: support rf212 and extended mac features
Date: Fri, 14 Feb 2014 23:49:22 +0100
Message-ID: <1392418172-5305-1-git-send-email-phoebe.buckheister@itwm.fraunhofer.de>
Cc: linux-zigbee-devel@lists.sourceforge.net, davem@davemloft.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from selenium.quasiparticle.net ([188.40.96.248]:43995 "EHLO
	quasiparticle.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752829AbaBNW6a (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 Feb 2014 17:58:30 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

this patch set adds support for the RF212 radio chip to the existing
at86rf230 driver and adds support for numerous features of the RF212
chips to the ieee802154 stack. These features include CSMA parameter
configuration, transmit power control, CCA parameter configuration, and
automatic retransmission of frames. Netlink APIs are provided for all
new options introduced in this set.

Many features might also work for RF230, but since I have no such chips
at my disposal, most new features are implemented only for RF212.

Changes since v1:
 * CodingStyle compliance. Thanks Sergei Shtylyov
 * Add CSMA parameters to netlink phy list that were forgotten in v1


Phoebe Buckheister (10):
      ieee802154: add basic support for RF212 to at86rf230 driver
      ieee802154: default to AACK in at86rf230
      ieee802154: add TX power control to wpan_phy
      ieee802154: support 100kbps QPSK/EU in at86rf230
      ieee802154: add support for listen-before-talk in wpan_phy
      ieee802154: add support for CCA mode in wpan phys
      ieee802154: add support for setting CCA energy detection levels
      ieee802154: ensure that first RF212 state comes from TRX_OFF
      ieee802154: add netlink APIs for smartMAC configuration
      ieee802154: enable smart transmitter features of RF212


 drivers/net/ieee802154/at86rf230.c | 435 +++++++++++++++++++++--------
 include/linux/nl802154.h           |  12 +
 include/net/mac802154.h            |  35 +++
 include/net/wpan-phy.h             |  19 +-
 net/ieee802154/ieee802154.h        |   1 +
 net/ieee802154/netlink.c           |   1 +
 net/ieee802154/nl-phy.c            | 198 ++++++++++++-
 net/ieee802154/nl_policy.c         |  10 +
 net/ieee802154/wpan-class.c        |  10 +-
 net/mac802154/ieee802154_dev.c     |  67 +++++
 10 files changed, 670 insertions(+), 118 deletions(-)
