From: Mark D Rustad <mark.d.rustad@intel.com>
Subject: [PATCH V3 0/2] pci: Provide a flag to access VPD through function 0
Date: Wed, 03 Jun 2015 11:46:53 -0700
Message-ID: <20150603184445.109080.36387.stgit@mdrustad-wks.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: linux-pci@vger.kernel.org, intel-wired-lan@lists.osuosl.org,
	netdev@vger.kernel.org
To: bhelgaas@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:64714 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753652AbbFCSqz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 3 Jun 2015 14:46:55 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

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
Changes in V3:
- Don't leak a device reference
- Check that function 0 has VPD
- Make a helper for the function 0 checks
- Moved a multifunction check to the quirk patch

---

Mark D Rustad (2):
      pci: Add dev_flags bit to access VPD through function 0
      pci: Add VPD quirk for Intel Ethernet devices


 drivers/pci/access.c |   61 +++++++++++++++++++++++++++++++++++++++++++++++++-
 drivers/pci/quirks.c |    9 +++++++
 2 files changed, 69 insertions(+), 1 deletion(-)

-- 
Mark Rustad, Network Division, Intel Corporation
