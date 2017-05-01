From: Casey Leedom <leedom@chelsio.com>
Subject: [PATCH 0/2] Add new PCI_DEV_FLAGS_NO_RELAXED_ORDERING flag
Date: Mon,  1 May 2017 16:13:49 -0700
Message-ID: <cover.1493678834.git.leedom@chelsio.com>
Cc: Casey Leedom <leedom@chelsio.com>,
        Michael Werner <werner@chelsio.com>,
        Ganesh Goudar <ganeshgr@chelsio.com>,
        Arjun V <arjun@chelsio.com>,
        David Miller <davem@davemloft.com>,
        Asit K Mallick <asit.k.mallick@intel.com>,
        Patrick J Cramer <patrick.j.cramer@intel.com>,
        Ashok Raj <ashok.raj@intel.com>,
        Suravee Suthikulpanit <Suravee.Suthikulpanit@amd.com>,
        Bob Shaw <Bob.Shaw@amd.com>, h <l.stach@pengutronix.de>,
        Alexander Duyck <alexander.duyck@gmail.com>,
        Ding Tianhong <dingtianhong@huawei.com>,
        Mark Rutland <mark.rutland@arm.com>,
        Amir Ancel <amira@mellanox.com>,
        Gabriele Paoloni <gabriele.paoloni@huawei.com>,
        Catalin Marinas <catalin.marinas@arm.com>,
        Will Deacon <will.deacon@arm.com>,
        LinuxArm <linuxarm@huawei.com>,
        David Laight <David.Laight@a
To: Bjorn Helgaas <helgaas@kernel.org>, leedom@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([12.32.117.8]:52568 "EHLO
        stargate.chelsio.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751008AbdEAXPK (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 1 May 2017 19:15:10 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Some devices have problems with Transaction Layer Packets with the Relaxed
Ordering Attribute set.  This patch set adds a new PCIe Device Flag,
PCI_DEV_FLAGS_NO_RELAXED_ORDERING, a set of PCI Quirks to catch some known
devices with Relaxed Ordering issues, and a use of this new flag by the
cxgb4 driver to avoid using Relaxed Ordering with problematic Root Complex
Ports.

It's been years since I've submitted kernel.org patches, I appolgise for the
almost certain submission errors.

Casey Leedom (2):
  PCI: Add new PCIe Fabric End Node flag,
    PCI_DEV_FLAGS_NO_RELAXED_ORDERING
  net/cxgb4: Use new PCI_DEV_FLAGS_NO_RELAXED_ORDERING flag

 drivers/net/ethernet/chelsio/cxgb4/cxgb4.h      |  1 +
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c | 17 +++++++++++
 drivers/net/ethernet/chelsio/cxgb4/sge.c        |  5 ++--
 drivers/pci/quirks.c                            | 38 +++++++++++++++++++++++++
 include/linux/pci.h                             |  2 ++
 5 files changed, 61 insertions(+), 2 deletions(-)

-- 
1.9.1
