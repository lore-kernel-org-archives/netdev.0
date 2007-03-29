From: "Kok, Auke" <auke-jan.h.kok@intel.com>
Subject: [PATCH 00/19] e1000: hardware init layer update, new internal API
Date: Thu, 29 Mar 2007 09:33:04 -0700
Message-ID: <20070329163304.6595.81963.stgit@localhost.localdomain>
Content-Type: text/plain; charset=utf-8; format=fixed
Content-Transfer-Encoding: 8bit
Cc: auke-jan.h.kok@intel.com, bruce.w.allan@intel.com,
	jeffrey.t.kirsher@intel.com, jesse.brandeburg@intel.com,
	cramerj@intel.com, john.ronciak@intel.com,
	arjan.van.de.ven@intel.com, akpm@linux-foundation.org,
	netdev@vger.kernel.org
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:36465 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1030358AbXC2Qj7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 29 Mar 2007 12:39:59 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Hi,

This single patch split out over several e-mails creates an e1000 hardware-
independent API for accessing MAC, PHY, NVM and manageability.

The API adds function pointers for common entry points into the code
and relieves the driver from doing lots of mac_type switch statements,
allowing us to minimize the risk of introducing regressions when adding
new hardware support to e1000. Code path separation also will allow
us in the future to specifically enable only support for chipsets that
the user needs in the case of embedded systems.

The e1000 family of adapters currently consists of 7 distinctly different
adapters. The family-specific code has been split out into one file per
family. PHY, NVM and manageability infrastructure code has also been
split out in a separate file per component.

This change forces us to rewrite some of the register sets, particularly
since the e1000 chipsets currently operate with two completely different
register mappings. All the generic register defines are extracted into
a separate container, while maintaining compatibility with the 82542
register set.

This patch is dependent on both the upstream and e1000-fixes branch of
jgarzik/netdev-2.6.

The entire set of changes is available as a single git-commit to
allow regression testing and bisecting to work as expected, but for
convencience split up into several e-mails. Patch #7 will be missing
from the netdev ML since it exceeds 100k, but it contains the removal
of e1000_hw.c, and as such should not be missed too much.

For convenience, all the patches can be viewed together with other
patches in my queue here:

http://foo-projects.org/~sofar/patches-20070327/

---
Jeff,

Please consider pulling from:

git://lost.foo-projects.org/~ahkok/git/netdev-2.6 e1000

Which is a tree based on both the e1000-fixes (prerequisite to this patch)
and your upstream tree.

---
Signed-off-by: Bruce Allan <bruce.w.allan@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
Signed-off-by: Jeb Cramer <cramerj@intel.com>
Signed-off-by: John Ronciak <john.ronciak@intel.com>
Signed-off-by: Auke Kok <auke-jan.h.kok@intel.com>

---
 drivers/net/e1000/Makefile            |   18 +-
 drivers/net/e1000/e1000.h             |    7 +
 drivers/net/e1000/e1000_80003es2lan.c | 1377 +++++
 drivers/net/e1000/e1000_80003es2lan.h |   89 +
 drivers/net/e1000/e1000_82540.c       |  670 +++
 drivers/net/e1000/e1000_82541.c       | 1305 +++++
 drivers/net/e1000/e1000_82541.h       |   86 +
 drivers/net/e1000/e1000_82542.c       |  551 ++
 drivers/net/e1000/e1000_82543.c       | 1643 ++++++
 drivers/net/e1000/e1000_82543.h       |   45 +
 drivers/net/e1000/e1000_82571.c       | 1333 +++++
 drivers/net/e1000/e1000_82571.h       |   42 +
 drivers/net/e1000/e1000_api.c         | 1174 +++++
 drivers/net/e1000/e1000_api.h         |  160 +
 drivers/net/e1000/e1000_defines.h     | 1303 +++++
 drivers/net/e1000/e1000_ethtool.c     |  503 ++-
 drivers/net/e1000/e1000_hw.c          | 9038 ---------------------------------
 drivers/net/e1000/e1000_hw.h          | 3857 +++------------
 drivers/net/e1000/e1000_ich8lan.c     | 2443 +++++++++
 drivers/net/e1000/e1000_ich8lan.h     |  110 +
 drivers/net/e1000/e1000_mac.c         | 1939 +++++++
 drivers/net/e1000/e1000_mac.h         |   84 +
 drivers/net/e1000/e1000_main.c        | 1034 ++--
 drivers/net/e1000/e1000_manage.c      |  384 ++
 drivers/net/e1000/e1000_manage.h      |   83 +
 drivers/net/e1000/e1000_nvm.c         |  859 ++++
 drivers/net/e1000/e1000_nvm.h         |   60 +
 drivers/net/e1000/e1000_osdep.h       |   52 +-
 drivers/net/e1000/e1000_param.c       |   98 +-
 drivers/net/e1000/e1000_phy.c         | 1933 +++++++
 drivers/net/e1000/e1000_phy.h         |  159 +
 drivers/net/e1000/e1000_regs.h        |  261 +
 32 files changed, 19582 insertions(+), 13118 deletions(-)
 create mode 100644 drivers/net/e1000/e1000_80003es2lan.c
 create mode 100644 drivers/net/e1000/e1000_80003es2lan.h
 create mode 100644 drivers/net/e1000/e1000_82540.c
 create mode 100644 drivers/net/e1000/e1000_82541.c
 create mode 100644 drivers/net/e1000/e1000_82541.h
 create mode 100644 drivers/net/e1000/e1000_82542.c
 create mode 100644 drivers/net/e1000/e1000_82543.c
 create mode 100644 drivers/net/e1000/e1000_82543.h
 create mode 100644 drivers/net/e1000/e1000_82571.c
 create mode 100644 drivers/net/e1000/e1000_82571.h
 create mode 100644 drivers/net/e1000/e1000_api.c
 create mode 100644 drivers/net/e1000/e1000_api.h
 create mode 100644 drivers/net/e1000/e1000_defines.h
 delete mode 100644 drivers/net/e1000/e1000_hw.c
 create mode 100644 drivers/net/e1000/e1000_ich8lan.c
 create mode 100644 drivers/net/e1000/e1000_ich8lan.h
 create mode 100644 drivers/net/e1000/e1000_mac.c
 create mode 100644 drivers/net/e1000/e1000_mac.h
 create mode 100644 drivers/net/e1000/e1000_manage.c
 create mode 100644 drivers/net/e1000/e1000_manage.h
 create mode 100644 drivers/net/e1000/e1000_nvm.c
 create mode 100644 drivers/net/e1000/e1000_nvm.h
 create mode 100644 drivers/net/e1000/e1000_phy.c
 create mode 100644 drivers/net/e1000/e1000_phy.h
 create mode 100644 drivers/net/e1000/e1000_regs.h

---
Auke Kok <auke-jan.h.kok@intel.com>
