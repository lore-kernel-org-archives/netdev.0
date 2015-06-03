From: Mark D Rustad <mark.d.rustad@intel.com>
Subject: [PATCH V2 0/2] pci: Provide a flag to access VPD through function 0
Date: Tue, 02 Jun 2015 17:10:06 -0700
Message-ID: <20150603000645.71269.26134.stgit@mdrustad-wks.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: linux-pci@vger.kernel.org, intel-wired-lan@lists.osuosl.org,
	netdev@vger.kernel.org
To: bhelgaas@google.com
Return-path: <linux-pci-owner@vger.kernel.org>
Sender: linux-pci-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Many multi-function devices provide shared registers in extended
config space for accessing VPD. The behavior of these registers
means that the state must be tracked and access locked correctly
for accesses not to hang or worse. One way to meet these needs is
to always perform the accesses through function 0, thereby using
the state tracking and mutex that already exists.

To provide this behavior, add a dev_flags bit to indicate that this
should be done. This bit can then be set for any non-zero function
that needs to redirect such VPD access to function 0. Do not set
this bit on the zero function or there will be an infinite recursion.

The second patch uses this new flag to invoke this behavior on all
multi-function Intel Ethernet devices.

Signed-off-by: Mark Rustad <mark.d.rustad@intel.com>

---
Changes in V2:
- Corrected a spelling error in a log message
- Added checks to see that the referenced function 0 is reasonable

---

Mark D Rustad (2):
      pci: Add dev_flags bit to access VPD through function 0
      pci: Add VPD quirk for Intel Ethernet devices


 drivers/pci/access.c |   48 +++++++++++++++++++++++++++++++++++++++++++++++-
 drivers/pci/quirks.c |    9 +++++++++
 2 files changed, 56 insertions(+), 1 deletion(-)

-- 
Mark Rustad, Network Division, Intel Corporation
