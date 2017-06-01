From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 00/14][pull request] 40GbE Intel Wired LAN Driver Updates 2017-06-01
Date: Thu,  1 Jun 2017 14:38:26 -0700
Message-ID: <20170601213840.36286-1-jeffrey.t.kirsher@intel.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, netdev@vger.kernel.org,
        nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga04.intel.com ([192.55.52.120]:40283 "EHLO mga04.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751050AbdFAVi5 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 1 Jun 2017 17:38:57 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series contains updates to i40e, i40evf and the "new" AVF virtchnl.

This is the introduction of the Intel(R) Ethernet Adaptive Virtual
Function driver code and device ID, as presented at the NetDEV 1.2
conference in 2016.
http://netdevconf.org/1.2/session.html?anjali-singhai

The idea is to convert the interface between the i40evf driver
and the parent i40e PF driver to be generic, as the i40evf driver
should in the future be able to run on top of other Intel PF
drivers, and negotiate any features beyond a "base expected" set.

The following are changes since commit 0266f79778de0afadd070941aae493c28529d974:
  mlxsw: spectrum: Add bridge dependency for spectrum
and are available in the git repository at:
  git://git.kernel.org/pub/scm/linux/kernel/git/jkirsher/next-queue 40GbE

Jesse Brandeburg (11):
  i40evf: drop i40e_type.h include
  i40e/i40evf: create and use new unified header file
  i40e: use new unified virtchnl header file
  virtchnl: rename i40e to generic virtchnl
  virtchnl: move some code to core driver
  virtchnl: convert to new macros
  i40e/virtchnl: refactor code for validate checks
  i40evf/virtchnl: whitespace cleanups
  virtchnl: finish conversion to virtchnl interface
  i40e/virtchnl: move function to virtchnl
  i40evf: update i40evf.txt with new content

Preethi Banala (1):
  i40evf: Add support for Adaptive Virtual Function

Sridhar Samudrala (2):
  virtchnl: Add pad fields to a couple of structures
  virtchnl: Add compile time static asserts to validate structure sizes

 Documentation/networking/i40evf.txt                |  23 +-
 MAINTAINERS                                        |   1 +
 drivers/net/ethernet/intel/Kconfig                 |  10 +-
 drivers/net/ethernet/intel/i40e/i40e.h             |   2 +-
 drivers/net/ethernet/intel/i40e/i40e_client.c      |   2 +-
 drivers/net/ethernet/intel/i40e/i40e_common.c      |   2 +-
 drivers/net/ethernet/intel/i40e/i40e_prototype.h   |   6 +-
 drivers/net/ethernet/intel/i40e/i40e_virtchnl.h    | 449 -------------
 drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c | 474 +++++---------
 drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.h |   9 +-
 drivers/net/ethernet/intel/i40evf/i40e_common.c    |  15 +-
 drivers/net/ethernet/intel/i40evf/i40e_devids.h    |   1 +
 drivers/net/ethernet/intel/i40evf/i40e_prototype.h |   6 +-
 drivers/net/ethernet/intel/i40evf/i40e_virtchnl.h  | 448 -------------
 drivers/net/ethernet/intel/i40evf/i40evf.h         |  26 +-
 drivers/net/ethernet/intel/i40evf/i40evf_client.c  |  18 +-
 drivers/net/ethernet/intel/i40evf/i40evf_main.c    |  66 +-
 .../net/ethernet/intel/i40evf/i40evf_virtchnl.c    | 285 +++++----
 include/linux/avf/virtchnl.h                       | 701 +++++++++++++++++++++
 19 files changed, 1109 insertions(+), 1435 deletions(-)
 delete mode 100644 drivers/net/ethernet/intel/i40e/i40e_virtchnl.h
 delete mode 100644 drivers/net/ethernet/intel/i40evf/i40e_virtchnl.h
 create mode 100644 include/linux/avf/virtchnl.h

-- 
2.12.2
