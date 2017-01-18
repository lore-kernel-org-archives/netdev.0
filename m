From: Sainath Grandhi <sainath.grandhi@intel.com>
Subject: [PATCHv2 0/7] Refactor macvtap to re-use tap functionality by other virtual intefaces
Date: Tue, 17 Jan 2017 16:02:59 -0800
Message-ID: <1484697786-50323-1-git-send-email-sainath.grandhi@intel.com>
Cc: davem@davemloft.net, mahesh@bandewar.net,
        linux-kernel@vger.kernel.org, sainath.grandhi@intel.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:8811 "EHLO mga11.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752422AbdARAGY (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 17 Jan 2017 19:06:24 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

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
 drivers/net/ipvlan/ipvtap.c      |  238 +++++++
 drivers/net/macvlan.c            |    2 +-
 drivers/net/macvtap.c            | 1226 ++----------------------------------
 drivers/net/tap.c                | 1262 ++++++++++++++++++++++++++++++++++++++
 drivers/vhost/Kconfig            |    2 +-
 drivers/vhost/net.c              |    3 +-
 include/linux/if_macvlan.h       |   17 +-
 include/linux/if_tap.h           |   75 +++
 14 files changed, 1686 insertions(+), 1209 deletions(-)
 create mode 100644 drivers/net/ipvlan/ipvtap.c
 create mode 100644 drivers/net/tap.c
 create mode 100644 include/linux/if_tap.h

-- 
2.7.4
