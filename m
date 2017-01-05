From: Phil Sutter <phil@nwl.cc>
Subject: [net-next PATCH v6 0/3] net: dummy: Introduce dummy virtual functions
Date: Thu,  5 Jan 2017 20:09:10 +0100
Message-ID: <20170105190913.29986-1-phil@nwl.cc>
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbyte.nwl.cc ([151.80.46.58]:50367 "EHLO mail.nwl.cc"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1759198AbdAETJm (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 5 Jan 2017 14:09:42 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series adds VF support to dummy device driver after adding the
necessary infrastructure changes:

Patch 1 adds a netdevice callback for device-specific VF count
retrieval. Patch 2 then changes dev_num_vf() implementation to make use
of that new callback (if implemented), falling back to the old
behaviour. Patch 3 then implements VF support in dummy, without the fake
PCI parent device hack from v5.

Phil Sutter (3):
  net: net_device_ops: Introduce ndo_get_vf_count
  net: rtnetlink: Use a local dev_num_vf() implementation
  net: dummy: Introduce dummy virtual functions

 drivers/net/dummy.c       | 178 +++++++++++++++++++++++++++++++++++++++++++++-
 include/linux/netdevice.h |   5 ++
 include/linux/pci.h       |   2 -
 net/core/rtnetlink.c      |  37 ++++++----
 4 files changed, 205 insertions(+), 17 deletions(-)

-- 
2.11.0
