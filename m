From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next-2.6 PATCH 00/13] virtual function ixgbe driver
Date: Sat, 09 Jan 2010 04:22:54 -0800
Message-ID: <20100109120719.4462.66489.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta03.westchester.pa.mail.comcast.net ([76.96.62.32]:49693
	"EHLO qmta03.westchester.pa.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752768Ab0AIMXJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 9 Jan 2010 07:23:09 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The following series implements the ixgbevf driver.  This series of patches
has the following known issues:

- ixgbevf multiple load/unload can cause a panic
- loading ixgbevf before ixgbe does not work
- Tx hangs on VF interfaces - this happens when various resets, mostly due to
  ethtool operations are executed while passing traffic

We are looking for inclusion into net-next-2.6 so that we can get assistance
from the community in testing and further development of this driver.

---

Greg Rose (13):
      ixgbe: Fix ethtool diag test for VT mode operation
      ixgbe: Add SR-IOV features to main module
      ixgbe: Add SR-IOV feature enablement code
      ixgbe: Add SR-IOV specific modules to driver Makefile
      ixgbe: Add SR-IOV specific features
      ixgbe: Add SR-IOV register, structure and bit defines
      ixgbe: Mailbox header and code module
      ixgbevf: Kconfig, Makefile and Documentation
      ixgbevf: Driver Makefile
      ixgbevf: Driver main and ethool interface module and main header
      ixgbevf: Mailbox communication
      ixgbevf: 82599 Virtual Function core functions and header
      ixgbevf: Macros, data structures, useful defines and registers


 Documentation/networking/ixgbevf.txt |   90 +
 drivers/net/Kconfig                  |   22 
 drivers/net/Makefile                 |    1 
 drivers/net/ixgbe/Makefile           |    3 
 drivers/net/ixgbe/ixgbe.h            |   31 
 drivers/net/ixgbe/ixgbe_82599.c      |  126 +
 drivers/net/ixgbe/ixgbe_ethtool.c    |   11 
 drivers/net/ixgbe/ixgbe_main.c       |  280 +++
 drivers/net/ixgbe/ixgbe_mbx.c        |  479 +++++
 drivers/net/ixgbe/ixgbe_mbx.h        |   96 +
 drivers/net/ixgbe/ixgbe_sriov.c      |  336 +++
 drivers/net/ixgbe/ixgbe_sriov.h      |   45 
 drivers/net/ixgbe/ixgbe_type.h       |   53 +
 drivers/net/ixgbevf/Makefile         |   38 
 drivers/net/ixgbevf/defines.h        |  292 +++
 drivers/net/ixgbevf/ethtool.c        |  716 +++++++
 drivers/net/ixgbevf/ixgbevf.h        |  318 +++
 drivers/net/ixgbevf/ixgbevf_main.c   | 3571 ++++++++++++++++++++++++++++++++++
 drivers/net/ixgbevf/mbx.c            |  341 +++
 drivers/net/ixgbevf/mbx.h            |  100 +
 drivers/net/ixgbevf/regs.h           |   85 +
 drivers/net/ixgbevf/vf.c             |  387 ++++
 drivers/net/ixgbevf/vf.h             |  168 ++
 23 files changed, 7517 insertions(+), 72 deletions(-)
 create mode 100755 Documentation/networking/ixgbevf.txt
 create mode 100644 drivers/net/ixgbe/ixgbe_mbx.c
 create mode 100644 drivers/net/ixgbe/ixgbe_mbx.h
 create mode 100644 drivers/net/ixgbe/ixgbe_sriov.c
 create mode 100644 drivers/net/ixgbe/ixgbe_sriov.h
 create mode 100644 drivers/net/ixgbevf/Makefile
 create mode 100644 drivers/net/ixgbevf/defines.h
 create mode 100644 drivers/net/ixgbevf/ethtool.c
 create mode 100644 drivers/net/ixgbevf/ixgbevf.h
 create mode 100644 drivers/net/ixgbevf/ixgbevf_main.c
 create mode 100644 drivers/net/ixgbevf/mbx.c
 create mode 100644 drivers/net/ixgbevf/mbx.h
 create mode 100644 drivers/net/ixgbevf/regs.h
 create mode 100644 drivers/net/ixgbevf/vf.c
 create mode 100644 drivers/net/ixgbevf/vf.h

-- 
Cheers,
Jeff Kirsher
