From: Jakub Kicinski <jakub.kicinski@netronome.com>
Subject: [PATCH net-next 00/12] nfp: pci core, hwmon, live mac addr change
Date: Sat, 27 May 2017 17:33:59 -0700
Message-ID: <20170528003411.17603-1-jakub.kicinski@netronome.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Cc: oss-drivers@netronome.com,
        Jakub Kicinski <jakub.kicinski@netronome.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f173.google.com ([209.85.192.173]:36398 "EHLO
        mail-pf0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750762AbdE1Aem (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 27 May 2017 20:34:42 -0400
Received: by mail-pf0-f173.google.com with SMTP id m17so32499213pfg.3
        for <netdev@vger.kernel.org>; Sat, 27 May 2017 17:34:42 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series brings updates to core PCI code, SR-IOV, exposes 
firmware's capability to change MAC address at runtime and HWMON
interfaces.  

The PCI code updates include resiliency improvement in conditions 
which are quite unusual, but still shouldn't make the driver oops.
We also handle very large device memory operation more gracefully.
A timeout is added to acquiring mutexes in device memory.

Pablo provides a patch to expose to the stack the ability to change
MAC addresses under traffic while David adds HWMON interface for
reading device temperature and power consumption.

Last three patches are minor improvements to the netdev code.

David Brunecz (1):
  nfp: add hwmon support

Jakub Kicinski (10):
  nfp: set driver VF limit
  nfp: don't set aux pointers if ioremap failed
  nfp: only try to get to PCIe ctrl memory if BARs are wide enough
  nfp: support long reads and writes with the cpp helpers
  nfp: shorten CPP core probe logs
  nfp: support variable NSP response lengths
  nfp: don't wait for resources indefinitely
  nfp: fix print format for ring pointers in ring dumps
  nfp: don't add ring size to index calculations
  nfp: don't keep count for free buffers delayed kick

Pablo Cascón (1):
  nfp: add set_mac_address support while the interface is up

 drivers/net/ethernet/netronome/nfp/Makefile        |   1 +
 drivers/net/ethernet/netronome/nfp/nfp_hwmon.c     | 190 +++++++++++++++++++++
 drivers/net/ethernet/netronome/nfp/nfp_main.c      |  44 +++--
 drivers/net/ethernet/netronome/nfp/nfp_main.h      |   8 +
 drivers/net/ethernet/netronome/nfp/nfp_net.h       |   3 -
 .../net/ethernet/netronome/nfp/nfp_net_common.c    |  55 ++++--
 drivers/net/ethernet/netronome/nfp/nfp_net_ctrl.h  |   2 +
 .../net/ethernet/netronome/nfp/nfp_net_debugfs.c   |   4 +-
 drivers/net/ethernet/netronome/nfp/nfpcore/nfp.h   |   2 +
 .../ethernet/netronome/nfp/nfpcore/nfp6000_pcie.c  |  49 ++++--
 .../net/ethernet/netronome/nfp/nfpcore/nfp_cpp.h   |   8 +
 .../ethernet/netronome/nfp/nfpcore/nfp_cppcore.c   |  87 ++++++++--
 .../net/ethernet/netronome/nfp/nfpcore/nfp_mutex.c |   9 +-
 .../net/ethernet/netronome/nfp/nfpcore/nfp_nsp.c   |  16 ++
 .../net/ethernet/netronome/nfp/nfpcore/nfp_nsp.h   |  12 ++
 .../ethernet/netronome/nfp/nfpcore/nfp_nsp_cmds.c  |  47 ++++-
 .../ethernet/netronome/nfp/nfpcore/nfp_resource.c  |  10 +-
 17 files changed, 470 insertions(+), 77 deletions(-)
 create mode 100644 drivers/net/ethernet/netronome/nfp/nfp_hwmon.c

-- 
2.11.0
