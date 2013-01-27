From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 00/14][pull request] Intel Wired LAN Driver Updates 2013.01.27
Date: Sun, 27 Jan 2013 02:39:39 -0800
Message-ID: <1359283193-2043-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com, bruce.w.allan@intel.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:26342 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756426Ab3A0Kjz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 27 Jan 2013 05:39:55 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series contains updates to e1000e only.  All the updates come
from Bruce Allan and most of the patch fix or enable features on
i217/i218.  Most notably is patch 03 "e1000e: add support for IEEE-1588
PTP", which is v2 of the patch based on feedback from Stephen Hemminger.

Also patch 04 "e1000e: enable ECC on I217/I218 to catch packet buffer
memory errors" should be queued up for stable (as well as net) trees, but
the patch does not apply cleanly to either of those trees currently.
So I will work with Bruce to provide a version of the patch which will
apply cleanly to net (and stable) and we can queue it up at that point
for stable 3.5 tree.

The remaining patches are general cleanups of the code.

The following are changes since commit 031554eab078705edb96e9a39665597e3fd22781:
  Merge branch 'master' of git://git.kernel.org/pub/scm/linux/kernel/git/jkirsher/net-next
and are available in the git repository at:
  git://git.kernel.org/pub/scm/linux/kernel/git/jkirsher/net-next master

Bruce Allan (14):
  e1000e: fix ethtool offline register test for I217
  e1000e: fix flow-control thresholds for jumbo frames on
    82579/I217/I218
  e1000e: add support for IEEE-1588 PTP
  e1000e: enable ECC on I217/I218 to catch packet buffer memory errors
  e1000e: prevent hardware from automatically configuring PHY on
    I217/I218
  e1000e: remove prototype of non-existent function
  e1000e: update copyright date
  e1000e: correct maximum frame size on i217/i218
  e1000e: fix PHY init workarounds for i217/i218
  e1000e: remove definition of struct which is no longer used
  e1000e: add comment to spinlock_t definition
  e1000e: cleanup: remove unnecessary function prototypes
  e1000e: do not ignore variables which get set a value
  e1000e: cleanup: do not assign a variable a value when not necessary

 drivers/net/ethernet/intel/Kconfig              |   1 +
 drivers/net/ethernet/intel/e1000e/80003es2lan.c |  24 ++-
 drivers/net/ethernet/intel/e1000e/82571.c       |  18 +-
 drivers/net/ethernet/intel/e1000e/Makefile      |   4 +-
 drivers/net/ethernet/intel/e1000e/defines.h     |  22 +-
 drivers/net/ethernet/intel/e1000e/e1000.h       |  17 +-
 drivers/net/ethernet/intel/e1000e/ethtool.c     |  43 +++-
 drivers/net/ethernet/intel/e1000e/hw.h          |  15 +-
 drivers/net/ethernet/intel/e1000e/ich8lan.c     |  66 +++---
 drivers/net/ethernet/intel/e1000e/mac.c         |   4 +-
 drivers/net/ethernet/intel/e1000e/manage.c      |   2 +-
 drivers/net/ethernet/intel/e1000e/netdev.c      | 178 +++++++++++++--
 drivers/net/ethernet/intel/e1000e/nvm.c         |   2 +-
 drivers/net/ethernet/intel/e1000e/param.c       |   2 +-
 drivers/net/ethernet/intel/e1000e/phy.c         |  13 +-
 drivers/net/ethernet/intel/e1000e/ptp.c         | 276 ++++++++++++++++++++++++
 16 files changed, 587 insertions(+), 100 deletions(-)
 create mode 100644 drivers/net/ethernet/intel/e1000e/ptp.c

-- 
1.7.11.7
