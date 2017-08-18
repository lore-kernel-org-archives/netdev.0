From: Ding Tianhong <dingtianhong@huawei.com>
Subject: [PATCH v3 net 0/2] net: ixgbe: Use new flag to disable Relaxed Ordering
Date: Fri, 18 Aug 2017 14:21:03 +0800
Message-ID: <1503037265-11144-1-git-send-email-dingtianhong@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Mao Wenan <maowenan@huawei.com>
To: <davem@davemloft.net>, <jeffrey.t.kirsher@intel.com>,
        <keescook@chromium.org>, <linux-kernel@vger.kernel.org>,
        <sparclinux@vger.kernel.org>, <intel-wired-lan@lists.osuosl.org>,
        <alexander.duyck@gmail.com>, <netdev@vger.kernel.org>,
        <linuxarm@huawei.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Mao Wenan <maowenan@huawei.com>

The new flag PCI_DEV_FLAGS_NO_RELAXED_ORDERING has been added
to indicate that Relaxed Ordering Attributes (RO) should not
be used for Transaction Layer Packets (TLP) targeted toward
these affected Root Port, it will clear the bit4 in the PCIe
Device Control register, so the PCIe device drivers could
query PCIe configuration space to determine if it can send
TLPs to Root Port with the Relaxed Ordering Attributes set.

The ixgbe driver could use this flag to determine if it can
send TLPs to Root Port with the Relaxed Ordering Attributes set.

v2: Simplify the original program according Alex's suggestion,
    remove the new ixgbe flag2 and only check the bit4 in the
    PCIe Device Control register. 

v3: Remove the code that clears the bits in DCA_T/RXCTRL, relaxed
    ordering should be enabled by the HW when the bus allow it.

Ding Tianhong (2):
  Revert commit 1a8b6d76dc5b ("net:add one common config...")
  net: ixgbe: Use new IXGBE_FLAG2_ROOT_NO_RELAXED_ORDERING flag

 arch/Kconfig                                    |  3 --
 arch/sparc/Kconfig                              |  1 -
 drivers/net/ethernet/intel/ixgbe/ixgbe_82598.c  | 37 ++++++++++++-------------
 drivers/net/ethernet/intel/ixgbe/ixgbe_common.c | 32 +++++++++++----------
 4 files changed, 35 insertions(+), 38 deletions(-)

-- 
1.8.3.1
