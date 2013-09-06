From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net v6 0/8][pull request] Intel Wired LAN Driver Updates
Date: Fri,  6 Sep 2013 16:41:07 -0700
Message-ID: <1378510875-10704-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com, jesse.brandeburg@intel.com,
	shannon.nelson@intel.com, peter.p.waskiewicz.jr@intel.com,
	e1000-devel@lists.sourceforge.net
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:3308 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750754Ab3IFXlV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 6 Sep 2013 19:41:21 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series implements the new i40e driver for Intel's upcoming
Intel(R) Ethernet Controller XL710 Family of devices.

V1: initial send
V2: each patch has individual comments, in general, feedback from the
    list was applied and addressed. Many changes due to internal review
    and coding as well.
V3: many more individual comments addressed, thanks reviewers!  Many
    other changes due to internal review and development.
V4: addresses remaining community comments, mostly trivial edits.
    major sparse based cleanup of possible endian issues
    removal of most of __func__ references
    sizeof(*var) instead of sizeof(struct ...)
    change 'NULL ==' tests to !NULL
    implement xps
    use kernel bitshift macros (upper_32_bits, etc)
V5: remove sysfs support from this set, will rearchitect
    changes from community comments
V6: rename Kbuild to Makefile
    rename i40e_mem[set|cpy] to regular memset/memcpy

Let me start by saying thanks and we appreciate any time spent by
those of you who review and comment on this new driver, and we will
attempt to address and respond to all issues brought to our attention.

I tried to break the patches up to ease review, but the series should
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

To be clear, the driver development model and interaction with
community submitted patches *will not be any different* than what
we are currently doing today.

This driver *does* use some code (as our previous drivers do) that is
meant to be shared to different OS drivers.  One of the following
patches has the majority of this code in it, and is clearly called out
in the commit message.

An associated i40evf driver has been posted for review.

List of tools we ran in preparation:
way more sparse clean
make W=1, W=2 clean
checkpatch (almost) clean
        total: 1 errors, 4 warnings, 30595 lines checked
        NOTE: Ignored message types: LONG_LINE
        - issues have been addressed and the remainders
          are noise.
codespell clean
smatch (almost) clean with a couple minor warnings
coccicheck clean
namespacecheck clean
allmodconfig clean
ppc64 build clean (unable to test yet)

This driver is a team effort, thank you to Joseph Gasparakis,
Shannon Nelson, Anjali Singhai-Jain, Mitch Williams, Neerav
Parikh, Vasu Dev, Kavindya Deegala, Yi Zou, and PJ Waskiewicz.

TODO (known issues)
BQL implementation
finish rtnl_stat64 locking (we have a patch but debugging it)

The following are changes since commit 4e4f1fc226816905c937f9b29dabe351075dfe0f:
  tcp: properly increase rcv_ssthresh for ofo packets
and are available in the git repository at:
  git://git.kernel.org/pub/scm/linux/kernel/git/jkirsher/net master

Jesse Brandeburg (8):
  i40e: main driver core
  i40e: transmit, receive, and napi
  i40e: driver ethtool core
  i40e: driver core headers
  i40e: implement virtual device interface
  i40e: init code and hardware support
  i40e: debugfs interface
  i40e: include i40e in kernel proper

 Documentation/networking/00-INDEX                  |    2 +
 Documentation/networking/i40e.txt                  |  115 +
 MAINTAINERS                                        |    3 +-
 drivers/net/ethernet/intel/Kconfig                 |   18 +
 drivers/net/ethernet/intel/Makefile                |    1 +
 drivers/net/ethernet/intel/i40e/Makefile           |   44 +
 drivers/net/ethernet/intel/i40e/i40e.h             |  565 ++
 drivers/net/ethernet/intel/i40e/i40e_adminq.c      |  980 +++
 drivers/net/ethernet/intel/i40e/i40e_adminq.h      |  112 +
 drivers/net/ethernet/intel/i40e/i40e_adminq_cmd.h  | 2076 ++++++
 drivers/net/ethernet/intel/i40e/i40e_alloc.h       |   59 +
 drivers/net/ethernet/intel/i40e/i40e_common.c      | 2045 ++++++
 drivers/net/ethernet/intel/i40e/i40e_debugfs.c     | 2082 ++++++
 drivers/net/ethernet/intel/i40e/i40e_diag.c        |  133 +
 drivers/net/ethernet/intel/i40e/i40e_diag.h        |   52 +
 drivers/net/ethernet/intel/i40e/i40e_ethtool.c     | 1450 ++++
 drivers/net/ethernet/intel/i40e/i40e_hmc.c         |  366 +
 drivers/net/ethernet/intel/i40e/i40e_hmc.h         |  245 +
 drivers/net/ethernet/intel/i40e/i40e_lan_hmc.c     | 1006 +++
 drivers/net/ethernet/intel/i40e/i40e_lan_hmc.h     |  169 +
 drivers/net/ethernet/intel/i40e/i40e_main.c        | 7385 ++++++++++++++++++++
 drivers/net/ethernet/intel/i40e/i40e_nvm.c         |  391 ++
 drivers/net/ethernet/intel/i40e/i40e_osdep.h       |   82 +
 drivers/net/ethernet/intel/i40e/i40e_prototype.h   |  239 +
 drivers/net/ethernet/intel/i40e/i40e_register.h    | 4688 +++++++++++++
 drivers/net/ethernet/intel/i40e/i40e_status.h      |  101 +
 drivers/net/ethernet/intel/i40e/i40e_txrx.c        | 1817 +++++
 drivers/net/ethernet/intel/i40e/i40e_txrx.h        |  259 +
 drivers/net/ethernet/intel/i40e/i40e_type.h        | 1154 +++
 drivers/net/ethernet/intel/i40e/i40e_virtchnl.h    |  368 +
 drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c | 2407 +++++++
 drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.h |  121 +
 32 files changed, 30534 insertions(+), 1 deletion(-)
 create mode 100644 Documentation/networking/i40e.txt
 create mode 100644 drivers/net/ethernet/intel/i40e/Makefile
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
 create mode 100644 drivers/net/ethernet/intel/i40e/i40e_txrx.c
 create mode 100644 drivers/net/ethernet/intel/i40e/i40e_txrx.h
 create mode 100644 drivers/net/ethernet/intel/i40e/i40e_type.h
 create mode 100644 drivers/net/ethernet/intel/i40e/i40e_virtchnl.h
 create mode 100644 drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c
 create mode 100644 drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.h

-- 
1.8.3.1
