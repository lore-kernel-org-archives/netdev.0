From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next v2 0/8][pull request] Intel Wired LAN Driver Updates
Date: Thu, 22 Aug 2013 19:15:34 -0700
Message-ID: <1377224142-25160-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:40315 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752247Ab3HWCQT (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 22 Aug 2013 22:16:19 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series implements the new i40e driver for Intel's upcoming
Intel(R) Ethernet Controller XL710 Family of devices.

Let me start by saying thanks and we appreciate any time spent by
those of you who review and comment on this new driver, and we will
attempt to address and respond to all issues brought to our attention.

Jesse tried to break the patches up to ease review, but the series should
apply and still be bisectable, as the last patch adds the driver to
the kernel compile with CONFIG_I40E.

This driver is for a brand new bit of silicon that has a different
design than other Intel Ethernet silicon, and therefore needed a new
driver.

The hardware has quite a bit of capability and this driver is only
meant to provide basic functionality at first.  Future patches will
continue to add functionality and bug fixes.

This initial release is very early in the product cycle with the intent
of getting initial support into the kernel before users have the
hardware available to purchase.  A software development manual is not
ready yet but will be available when the hardware ships.

This driver *does* use some code (as our previous drivers do) that is
meant to be shared to different OS drivers.  One of the following
patches has the majority of this code in it, and is clearly called out
in the commit message.

An associated i40evf driver will follow in the future.

List of tools we ran in preparation:
sparse clean
make W=1, W=2 clean
checkpatch (almost) clean
        - total: 1 errors, 30 warnings, 31068 lines checked
        - NOTE: Ignored message types: LONG_LINE
        - 30 warnings/1 error are bogus and 1 is a bug in checkpatch
        - long lines that remain are #defines best on one line
codespell clean
smatch (almost) clean with a couple minor warnings
coccicheck clean
namespacecheck clean
allmodconfig clean
ppc64 build clean (unable to test yet)

This driver is a team effort, thank you to Joseph Gasparakis,
Shannon Nelson, Anjali Singhai-Jain, Mitch Williams, Neerav
Parikh, Vasu Dev, Yi Zou, and PJ Waskiewicz.

TODO (known issues)
BQL implementation
finish rtnl_stat64 locking (we have a patch but debugging it)

V1: initial send
V2: each patch has individual comments, in general, feedback from the
    list was applied and addressed. Many changes due to internal review
    and coding as well.

The following are changes since commit f925d0a62db3f1b6e463ef956d0855006538d002:
  net: tcp_probe: add IPv6 support
and are available in the git repository at:
  git://git.kernel.org/pub/scm/linux/kernel/git/jkirsher/net-next master

Jesse Brandeburg (8):
  i40e: main driver core
  i40e: transmit, receive, and napi
  i40e: driver ethtool core
  i40e: driver core headers
  i40e: implement virtual device interface
  i40e: init code and hardware support
  i40e: sysfs and debugfs interfaces
  i40e: include i40e in kernel proper

 Documentation/networking/00-INDEX                  |    2 +
 Documentation/networking/i40e.txt                  |  115 +
 MAINTAINERS                                        |    3 +-
 drivers/net/ethernet/intel/Kconfig                 |   18 +
 drivers/net/ethernet/intel/Makefile                |    1 +
 drivers/net/ethernet/intel/i40e/Kbuild             |   45 +
 drivers/net/ethernet/intel/i40e/i40e.h             |  541 ++
 drivers/net/ethernet/intel/i40e/i40e_adminq.c      |  976 +++
 drivers/net/ethernet/intel/i40e/i40e_adminq.h      |  112 +
 drivers/net/ethernet/intel/i40e/i40e_adminq_cmd.h  | 2071 ++++++
 drivers/net/ethernet/intel/i40e/i40e_alloc.h       |   59 +
 drivers/net/ethernet/intel/i40e/i40e_common.c      | 2033 ++++++
 drivers/net/ethernet/intel/i40e/i40e_debugfs.c     | 2234 ++++++
 drivers/net/ethernet/intel/i40e/i40e_diag.c        |  133 +
 drivers/net/ethernet/intel/i40e/i40e_diag.h        |   52 +
 drivers/net/ethernet/intel/i40e/i40e_ethtool.c     | 1413 ++++
 drivers/net/ethernet/intel/i40e/i40e_hmc.c         |  370 +
 drivers/net/ethernet/intel/i40e/i40e_hmc.h         |  246 +
 drivers/net/ethernet/intel/i40e/i40e_lan_hmc.c     | 1004 +++
 drivers/net/ethernet/intel/i40e/i40e_lan_hmc.h     |  170 +
 drivers/net/ethernet/intel/i40e/i40e_main.c        | 7520 ++++++++++++++++++++
 drivers/net/ethernet/intel/i40e/i40e_nvm.c         |  347 +
 drivers/net/ethernet/intel/i40e/i40e_osdep.h       |   83 +
 drivers/net/ethernet/intel/i40e/i40e_prototype.h   |  240 +
 drivers/net/ethernet/intel/i40e/i40e_register.h    | 4688 ++++++++++++
 drivers/net/ethernet/intel/i40e/i40e_status.h      |  101 +
 drivers/net/ethernet/intel/i40e/i40e_sysfs.c       |  627 ++
 drivers/net/ethernet/intel/i40e/i40e_txrx.c        | 1824 +++++
 drivers/net/ethernet/intel/i40e/i40e_txrx.h        |  259 +
 drivers/net/ethernet/intel/i40e/i40e_type.h        | 1157 +++
 drivers/net/ethernet/intel/i40e/i40e_virtchnl.h    |  368 +
 drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c | 2437 +++++++
 drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.h |  123 +
 33 files changed, 31371 insertions(+), 1 deletion(-)
 create mode 100644 Documentation/networking/i40e.txt
 create mode 100644 drivers/net/ethernet/intel/i40e/Kbuild
 create mode 100644 drivers/net/ethernet/intel/i40e/i40e.h
 create mode 100644 drivers/net/ethernet/intel/i40e/i40e_adminq.c
 create mode 100644 drivers/net/ethernet/intel/i40e/i40e_adminq.h
 create mode 100644 drivers/net/ethernet/intel/i40e/i40e_adminq_cmd.h
 create mode 100644 drivers/net/ethernet/intel/i40e/i40e_alloc.h
 create mode 100644 drivers/net/ethernet/intel/i40e/i40e_common.c
 create mode 100644 drivers/net/ethernet/intel/i40e/i40e_debugfs.c
 create mode 100644 drivers/net/ethernet/intel/i40e/i40e_diag.c
 create mode 100644 drivers/net/ethernet/intel/i40e/i40e_diag.h
 create mode 100644 drivers/net/ethernet/intel/i40e/i40e_ethtool.c
 create mode 100644 drivers/net/ethernet/intel/i40e/i40e_hmc.c
 create mode 100644 drivers/net/ethernet/intel/i40e/i40e_hmc.h
 create mode 100644 drivers/net/ethernet/intel/i40e/i40e_lan_hmc.c
 create mode 100644 drivers/net/ethernet/intel/i40e/i40e_lan_hmc.h
 create mode 100644 drivers/net/ethernet/intel/i40e/i40e_main.c
 create mode 100644 drivers/net/ethernet/intel/i40e/i40e_nvm.c
 create mode 100644 drivers/net/ethernet/intel/i40e/i40e_osdep.h
 create mode 100644 drivers/net/ethernet/intel/i40e/i40e_prototype.h
 create mode 100644 drivers/net/ethernet/intel/i40e/i40e_register.h
 create mode 100644 drivers/net/ethernet/intel/i40e/i40e_status.h
 create mode 100644 drivers/net/ethernet/intel/i40e/i40e_sysfs.c
 create mode 100644 drivers/net/ethernet/intel/i40e/i40e_txrx.c
 create mode 100644 drivers/net/ethernet/intel/i40e/i40e_txrx.h
 create mode 100644 drivers/net/ethernet/intel/i40e/i40e_type.h
 create mode 100644 drivers/net/ethernet/intel/i40e/i40e_virtchnl.h
 create mode 100644 drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c
 create mode 100644 drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.h

-- 
1.8.3.1
