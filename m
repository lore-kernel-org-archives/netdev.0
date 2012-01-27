From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 00/11][pull request] Intel Wired LAN Driver Updates
Date: Thu, 26 Jan 2012 19:08:38 -0800
Message-ID: <1327633729-14086-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:35567 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752361Ab2A0DIy (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 26 Jan 2012 22:08:54 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The following series contains updates to e1000e only.  This is the
second batch of e1000e patches and these changes contain
fixups/cleanups/conversions.  Most notably is the split up of lib.c
into mac.c, manage.c and nvm.c.

The following are changes since commit a7563f342db6490e66dbf2c8a50577a72a158c9a:
  ipv6: Use ipv6_addr_any()
and are available in the git repository at:
  git://git.kernel.org/pub/scm/linux/kernel/git/jkirsher/net-next master

Bruce Allan (11):
  e1000e: disable Early Receive DMA on ICH LOMs
  e1000e: update workaround for 82579 intermittently disabled during
    S0->Sx
  e1000e: ICHx/PCHx LOMs should use LPLU setting in NVM when going to
    Sx
  e1000e: increase Rx PBA to prevent dropping received packets on
    82566/82567
  e1000e: conditionally restart autoneg on 82577/8/9 when setting LPLU
    state
  e1000e: concatenate long debug strings which span multiple lines
  e1000e: convert final strncpy() to strlcpy()
  e1000e: increase version number
  e1000e: call er16flash() instead of __er16flash()
  e1000e: split lib.c into three more-appropriate files
  e1000e: update copyright year

 drivers/net/ethernet/intel/e1000e/80003es2lan.c    |    5 +-
 drivers/net/ethernet/intel/e1000e/82571.c          |    2 +-
 drivers/net/ethernet/intel/e1000e/Makefile         |    5 +-
 drivers/net/ethernet/intel/e1000e/defines.h        |    2 +-
 drivers/net/ethernet/intel/e1000e/e1000.h          |    4 +-
 drivers/net/ethernet/intel/e1000e/ethtool.c        |    2 +-
 drivers/net/ethernet/intel/e1000e/hw.h             |    2 +-
 drivers/net/ethernet/intel/e1000e/ich8lan.c        |  141 ++--
 drivers/net/ethernet/intel/e1000e/{lib.c => mac.c} | 1041 +-------------------
 drivers/net/ethernet/intel/e1000e/manage.c         |  377 +++++++
 drivers/net/ethernet/intel/e1000e/netdev.c         |   72 +-
 drivers/net/ethernet/intel/e1000e/nvm.c            |  647 ++++++++++++
 drivers/net/ethernet/intel/e1000e/param.c          |    2 +-
 drivers/net/ethernet/intel/e1000e/phy.c            |    5 +-
 14 files changed, 1168 insertions(+), 1139 deletions(-)
 rename drivers/net/ethernet/intel/e1000e/{lib.c => mac.c} (64%)
 create mode 100644 drivers/net/ethernet/intel/e1000e/manage.c
 create mode 100644 drivers/net/ethernet/intel/e1000e/nvm.c

-- 
1.7.7.6
