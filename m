From: sainath.grandhi@intel.com
Subject: [PATCH RFC v1 0/3] Support for tap user-space access with veth interfaces
Date: Wed,  6 Sep 2017 17:34:24 -0700
Message-ID: <1504744467-79590-1-git-send-email-sainath.grandhi@intel.com>
Cc: davem@davemloft.net, Sainath Grandhi <sainath.grandhi@intel.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([134.134.136.65]:34859 "EHLO mga03.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752021AbdIGAhq (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 6 Sep 2017 20:37:46 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sainath Grandhi <sainath.grandhi@intel.com>

This patchset adds a tap device driver for veth virtual network interface.
With this implementation, tap character interface can be added only to the
peer veth interface. Adding tap interface to veth is for usecases that forwards 
packets between host and VMs. This eliminates the need for an additional 
software bridge. This can be extended to create both the peer interfaces as
tap interfaces. These patches are a step in that direction.

Sainath Grandhi (3):
  net: Adding API to parse IFLA_LINKINFO attribute
  net: Abstracting out common routines from veth for use by vethtap
  vethtap: veth based tap driver

 drivers/net/Kconfig                 |   1 +
 drivers/net/Makefile                |   2 +
 drivers/net/{veth.c => veth_main.c} |  80 ++++++++++---
 drivers/net/vethtap.c               | 216 ++++++++++++++++++++++++++++++++++++
 include/linux/if_veth.h             |  13 +++
 include/net/rtnetlink.h             |   3 +
 net/core/rtnetlink.c                |   8 ++
 7 files changed, 308 insertions(+), 15 deletions(-)
 rename drivers/net/{veth.c => veth_main.c} (89%)
 create mode 100644 drivers/net/vethtap.c
 create mode 100644 include/linux/if_veth.h

-- 
2.7.4
