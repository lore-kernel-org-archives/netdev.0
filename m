From: Sainath Grandhi <sainath.grandhi@intel.com>
Subject: [PATCHv3 0/7] Refactor macvtap to re-use tap functionality by other virtual intefaces
Date: Wed, 25 Jan 2017 13:25:32 -0800
Message-ID: <1485379539-32932-1-git-send-email-sainath.grandhi@intel.com>
Cc: davem@davemloft.net, mahesh@bandewar.net,
        linux-kernel@vger.kernel.org, sainath.grandhi@intel.com
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Tap character devices can be implemented on other virtual interfaces like
ipvlan, similar to macvtap. Source code for tap functionality in macvtap
can be re-used for this purpose.

This patch series splits macvtap source into two modules, macvtap and tap.
This patch series also includes a patch for implementing tap character
device driver based on the IP-VLAN network interface, called ipvtap.

These patches are tested on x86 platform.

Sainath Grandhi (7):
  TAP: Refactoring macvtap.c
  TAP: Renaming tap related APIs, data structures, macros
  TAP: Tap character device creation/destroy API
  TAP: Abstract type of virtual interface from tap  implementation
  TAP: Extending tap device create/destroy APIs
  TAP: tap as an independent module
  IPVTAP: IP-VLAN based tap driver

 drivers/net/Kconfig              |   28 +
 drivers/net/Makefile             |    2 +
 drivers/net/ipvlan/Makefile      |    1 +
 drivers/net/ipvlan/ipvlan.h      |    7 +
 drivers/net/ipvlan/ipvlan_core.c |    5 +-
 drivers/net/ipvlan/ipvlan_main.c |   27 +-
 drivers/net/ipvlan/ipvtap.c      |  241 ++++++++
 drivers/net/macvlan.c            |    2 +-
 drivers/net/macvtap.c            | 1229 ++-----------------------------------
 drivers/net/tap.c                | 1261 ++++++++++++++++++++++++++++++++++++++
 drivers/vhost/Kconfig            |    2 +-
 drivers/vhost/net.c              |    3 +-
 include/linux/if_macvlan.h       |   17 +-
 include/linux/if_tap.h           |   75 +++
 14 files changed, 1691 insertions(+), 1209 deletions(-)
 create mode 100644 drivers/net/ipvlan/ipvtap.c
 create mode 100644 drivers/net/tap.c
 create mode 100644 include/linux/if_tap.h

-- 
2.7.4
