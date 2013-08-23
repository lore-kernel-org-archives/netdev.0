From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next RFC 0/7] Intel Wired LAN i40evf Driver
Date: Thu, 22 Aug 2013 21:53:22 -0700
Message-ID: <1377233609-11627-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([143.182.124.37]:11952 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754478Ab3HWExc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 23 Aug 2013 00:53:32 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series contains the addition of i40evf driver.

This driver is for the virtual functions of a bit of silicon that
has a different design than other Intel Ethernet silicon, and
therefore needed a new driver. The i40e driver (posted recently
by Jesse Brandeburg) controls the physical function of this
device, and is required for this driver to work.

This initial release is very early in the product cycle with the intent
of getting initial support into the kernel before users have the
hardware available to purchase.  A software development manual is not
ready yet but will be available when the hardware ships.

This driver *does* use some code (as our previous drivers do) that is
meant to be shared to different OS drivers.  One of the following
patches has the majority of this code in it, and is clearly called out
in the commit message.

The following are changes since commit d374aadcb8484a5562017b70831abf360781d6f2:
  i40e: include i40e in kernel proper

Mitch A Williams (7):
  i40evf: main driver core
  i40evf: transmit and receive
  i40evf: core ethtool functionality
  i40evf: virtual channel interface
  i40evf: driver core headers
  i40evf: init code and hardware support
  i40evf: add driver to kernel build system

 Documentation/networking/i40evf.txt                |   47 +
 MAINTAINERS                                        |    4 +-
 drivers/net/ethernet/intel/Kconfig                 |   19 +
 drivers/net/ethernet/intel/Makefile                |    1 +
 drivers/net/ethernet/intel/i40evf/Kbuild           |   36 +
 drivers/net/ethernet/intel/i40evf/i40e_adminq.c    |  951 ++++
 drivers/net/ethernet/intel/i40evf/i40e_adminq.h    |  112 +
 .../net/ethernet/intel/i40evf/i40e_adminq_cmd.h    | 2071 +++++++++
 drivers/net/ethernet/intel/i40evf/i40e_alloc.h     |   59 +
 drivers/net/ethernet/intel/i40evf/i40e_common.c    |  218 +
 drivers/net/ethernet/intel/i40evf/i40e_hmc.h       |  246 +
 drivers/net/ethernet/intel/i40evf/i40e_lan_hmc.h   |  170 +
 drivers/net/ethernet/intel/i40evf/i40e_osdep.h     |   76 +
 drivers/net/ethernet/intel/i40evf/i40e_prototype.h |   79 +
 drivers/net/ethernet/intel/i40evf/i40e_register.h  | 4688 ++++++++++++++++++++
 drivers/net/ethernet/intel/i40evf/i40e_status.h    |  101 +
 drivers/net/ethernet/intel/i40evf/i40e_txrx.c      | 1495 +++++++
 drivers/net/ethernet/intel/i40evf/i40e_txrx.h      |  258 ++
 drivers/net/ethernet/intel/i40evf/i40e_type.h      | 1156 +++++
 drivers/net/ethernet/intel/i40evf/i40e_virtchnl.h  |  368 ++
 drivers/net/ethernet/intel/i40evf/i40evf.h         |  330 ++
 drivers/net/ethernet/intel/i40evf/i40evf_ethtool.c |  411 ++
 drivers/net/ethernet/intel/i40evf/i40evf_main.c    | 2318 ++++++++++
 .../net/ethernet/intel/i40evf/i40evf_virtchnl.c    |  801 ++++
 24 files changed, 16014 insertions(+), 1 deletion(-)
 create mode 100644 Documentation/networking/i40evf.txt
 create mode 100644 drivers/net/ethernet/intel/i40evf/Kbuild
 create mode 100644 drivers/net/ethernet/intel/i40evf/i40e_adminq.c
 create mode 100644 drivers/net/ethernet/intel/i40evf/i40e_adminq.h
 create mode 100644 drivers/net/ethernet/intel/i40evf/i40e_adminq_cmd.h
 create mode 100644 drivers/net/ethernet/intel/i40evf/i40e_alloc.h
 create mode 100644 drivers/net/ethernet/intel/i40evf/i40e_common.c
 create mode 100644 drivers/net/ethernet/intel/i40evf/i40e_hmc.h
 create mode 100644 drivers/net/ethernet/intel/i40evf/i40e_lan_hmc.h
 create mode 100644 drivers/net/ethernet/intel/i40evf/i40e_osdep.h
 create mode 100644 drivers/net/ethernet/intel/i40evf/i40e_prototype.h
 create mode 100644 drivers/net/ethernet/intel/i40evf/i40e_register.h
 create mode 100644 drivers/net/ethernet/intel/i40evf/i40e_status.h
 create mode 100644 drivers/net/ethernet/intel/i40evf/i40e_txrx.c
 create mode 100644 drivers/net/ethernet/intel/i40evf/i40e_txrx.h
 create mode 100644 drivers/net/ethernet/intel/i40evf/i40e_type.h
 create mode 100644 drivers/net/ethernet/intel/i40evf/i40e_virtchnl.h
 create mode 100644 drivers/net/ethernet/intel/i40evf/i40evf.h
 create mode 100644 drivers/net/ethernet/intel/i40evf/i40evf_ethtool.c
 create mode 100644 drivers/net/ethernet/intel/i40evf/i40evf_main.c
 create mode 100644 drivers/net/ethernet/intel/i40evf/i40evf_virtchnl.c

-- 
1.8.3.1
