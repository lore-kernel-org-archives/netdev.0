From: Alexander Smirnov <alex.bluesman.smirnov-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: [PATCH series v2] IEEE 802.15.4 MAC layer
	basic implementation
Date: Mon, 26 Dec 2011 19:01:04 +0300
Message-ID: <CAJmB2rBMVvw_TV-mT2-jT7=H0adfMWaYFC0Q908pc_ND+PLD_g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "open list:NETWORKING \[GENERAL\]" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	linux-zigbee-devel <linux-zigbee-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
To: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
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

Dear David, colleagues,

I'm very sorry for the flood with my previous messages, problems with
mail client :-(

This is the second version of patch series which adds basic support for
IEEE 802.15.4 Medium Access Control layer.

The IEEE 802.15.4 Working Group focuses on the standardization of the
bottom two layers of ISO/OSI protocol stack: Physical (PHY) and MAC.
The MAC layer provides access control to a shared channel and reliable
data delivery.

This series provide only basic features:
 - interface for drivers registration
 - RX/TX datapaths
 - reduced mlme operations
 - monitor device type support (used by network sniffers, e.g. Wireshark)
 - IEEE 802.15.4 loopback driver
 - documentation update

With best regards,
Alexander

--

Changes since last post:
 * lots and lots of coding style and poor formating issues
 * additional comments
 * using proper byte order (little endian)
 * locking in loopback driver
 * mac802154: allocation of ieee802154 device: using of NETDEV_ALIGN,
 reworked like for ieee80211 stack (net/mac80211/main.c)
 The reason why I use alignment of data in ieee802154 layer is because of
 there are two levels of private data: mac layer's and driver's.

--

The following changes since commit eb93992207dadb946a3b5cf4544957dc924a6f58:

 module_param: make bool parameters really bool (net & drivers/net)
(2011-12-19 22:27:29 -0500)

are available in the git repository at:
 git://linux-zigbee.git.sourceforge.net/gitroot/linux-zigbee/kernel to_upstream

Alexander Smirnov (14):
    mac802154: basic ieee802.15.4 device structures
    mac802154: allocation of ieee802154 device
    mac802154: RX data path
    mac802154: TX data path
    mac802154: define reduced mlme operations
    mac802154: slave interfaces definition
    mac802154: reduced mlme operations
    mac802154: basic mib support
    ieee802154: remove ieee802154 policy from globals
    ieee802154: interface type to be added
    mac802154: slaves manipulation routine
    mac802154: monitor device support
    drivers/ieee802154: IEEE 802.15.4 loopback driver
    Documentation/networking/ieee802154: update MAC chapter

 Documentation/networking/ieee802154.txt |   75 ++++++--
 drivers/ieee802154/Kconfig              |    8 +
 drivers/ieee802154/Makefile             |    1 +
 drivers/ieee802154/fakelb.c             |  293 +++++++++++++++++++++++++++++++
 include/linux/if_arp.h                  |    1 +
 include/linux/nl802154.h                |   19 ++-
 include/net/ieee802154_netdev.h         |   26 +++-
 include/net/mac802154.h                 |  157 +++++++++++++++++
 include/net/wpan-phy.h                  |    5 +-
 net/Kconfig                             |    1 +
 net/Makefile                            |    1 +
 net/ieee802154/ieee802154.h             |    2 +
 net/ieee802154/nl-phy.c                 |    9 +-
 net/ieee802154/wpan-class.c             |    1 +
 net/mac802154/Kconfig                   |   16 ++
 net/mac802154/Makefile                  |    2 +
 net/mac802154/ieee802154_dev.c          |  269 ++++++++++++++++++++++++++++
 net/mac802154/mac802154.h               |  107 +++++++++++
 net/mac802154/mac_cmd.c                 |   43 +++++
 net/mac802154/mib.c                     |   97 ++++++++++
 net/mac802154/monitor.c                 |  115 ++++++++++++
 net/mac802154/rx.c                      |  110 ++++++++++++
 net/mac802154/tx.c                      |  113 ++++++++++++
 23 files changed, 1447 insertions(+), 24 deletions(-)
 create mode 100644 drivers/ieee802154/fakelb.c
 create mode 100644 include/net/mac802154.h
 create mode 100644 net/mac802154/Kconfig
 create mode 100644 net/mac802154/Makefile
 create mode 100644 net/mac802154/ieee802154_dev.c
 create mode 100644 net/mac802154/mac802154.h
 create mode 100644 net/mac802154/mac_cmd.c
 create mode 100644 net/mac802154/mib.c
 create mode 100644 net/mac802154/monitor.c
 create mode 100644 net/mac802154/rx.c
 create mode 100644 net/mac802154/tx.c

------------------------------------------------------------------------------
Write once. Port to many.
Get the SDK and tools to simplify cross-platform app development. Create 
new or port existing apps to sell to consumers worldwide. Explore the 
Intel AppUpSM program developer opportunity. appdeveloper.intel.com/join
http://p.sf.net/sfu/intel-appdev
