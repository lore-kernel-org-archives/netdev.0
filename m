From: Phoebe Buckheister <phoebe.buckheister-mPn0NPGs4xGatNDF+KUbs4QuADTiUCJX@public.gmane.org>
Subject: [PATCH net-next v3 0/10] ieee802154: support
	rf212 and extended mac features
Date: Mon, 17 Feb 2014 11:34:05 +0100
Message-ID: <1392633255-26605-1-git-send-email-phoebe.buckheister@itwm.fraunhofer.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org, linux-zigbee-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
To: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-zigbee-devel-bounces-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/linux-zigbee-devel>,
	<mailto:linux-zigbee-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=linux-zigbee-devel>
List-Post: <mailto:linux-zigbee-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
List-Help: <mailto:linux-zigbee-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/linux-zigbee-devel>,
	<mailto:linux-zigbee-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=subscribe>
Errors-To: linux-zigbee-devel-bounces-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
List-Id: netdev.vger.kernel.org

Hi,

this patch set adds support for the RF212 radio chip to the existing
at86rf230 driver and adds support for numerous features of the RF212
chips to the ieee802154 stack. These features include CSMA parameter
configuration, transmit power control, CCA parameter configuration, and
automatic retransmission of frames. Netlink APIs are provided for all
new options introduced in this set.

Many features might also work for RF230, but since I have no such chips
at my disposal, most new features are implemented only for RF212.

Changes since v2:
 * Indentation
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


 drivers/net/ieee802154/at86rf230.c | 433 +++++++++++++++++++++--------
 include/linux/nl802154.h           |  12 +
 include/net/mac802154.h            |  35 +++
 include/net/wpan-phy.h             |  19 +-
 net/ieee802154/ieee802154.h        |   1 +
 net/ieee802154/netlink.c           |   1 +
 net/ieee802154/nl-phy.c            | 198 ++++++++++++-
 net/ieee802154/nl_policy.c         |  10 +
 net/ieee802154/wpan-class.c        |  10 +-
 net/mac802154/ieee802154_dev.c     |  67 +++++
 10 files changed, 668 insertions(+), 118 deletions(-)


------------------------------------------------------------------------------
Android apps run on BlackBerry 10
Introducing the new BlackBerry 10.2.1 Runtime for Android apps.
Now with support for Jelly Bean, Bluetooth, Mapview and more.
Get your Android app in front of a whole new audience.  Start now.
http://pubads.g.doubleclick.net/gampad/clk?id=124407151&iu=/4140/ostg.clktrk
