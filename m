From: Phil Sutter <phil@nwl.cc>
Subject: [net-next PATCH 0/3] Retrieve number of VFs in a bus-agnostic way
Date: Wed, 18 Jan 2017 14:04:36 +0100
Message-ID: <20170118130439.15023-1-phil@nwl.cc>
Cc: netdev@vger.kernel.org, linux-pci@vger.kernel.org
To: David Miller <davem@davemloft.net>,
        Bjorn Helgaas <bhelgaas@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbyte.nwl.cc ([151.80.46.58]:41113 "EHLO mail.nwl.cc"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1754256AbdARNCA (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 18 Jan 2017 08:02:00 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Previously, it was assumed that only PCI NICs would be capable of having
virtual functions - with my proposed enhancement of dummy NIC driver
implementing (fake) ones for testing purposes, this is no longer true.

Discussion of said patch has led to the suggestion of implementing a
bus-agnostic method for VF count retrieval so rtnetlink could work with
both real VF-capable PCI NICs as well as my dummy modifications without
introducing ugly hacks.

The following series tries to achieve just that by introducing a bus
type callback to retrieve a device's number of VFs, implementing this
callback for PCI bus and finally adjusting rtnetlink to make use of the
generalized infrastructure.

Phil Sutter (3):
  device: bus_type: Introduce num_vf callback
  PCI: implement num_vf bus type callback
  device: Implement a bus agnostic dev_num_vf routine

 drivers/pci/pci-driver.c |  6 ++++++
 include/linux/device.h   | 11 +++++++++++
 include/linux/pci.h      |  2 --
 net/core/rtnetlink.c     |  3 +--
 4 files changed, 18 insertions(+), 4 deletions(-)

-- 
2.11.0
