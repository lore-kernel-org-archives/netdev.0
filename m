From: Jakub Kicinski <jakub.kicinski@netronome.com>
Subject: [PATCH net-next 00/15] nfp: allow concurrency in core and minor fixes
Date: Tue, 21 Mar 2017 17:59:06 -0700
Message-ID: <20170322005921.10965-1-jakub.kicinski@netronome.com>
Cc: oss-drivers@netronome.com, kubakici@wp.pl,
        Jakub Kicinski <jakub.kicinski@netronome.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f171.google.com ([209.85.192.171]:35713 "EHLO
        mail-pf0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S933083AbdCVBGs (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 21 Mar 2017 21:06:48 -0400
Received: by mail-pf0-f171.google.com with SMTP id 20so38786837pfk.2
        for <netdev@vger.kernel.org>; Tue, 21 Mar 2017 18:06:47 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi!

The first 10 patches of this series prepare nfpcore for concurrent 
accesses.  This will be needed by upcoming hwmon and devlink patches.
Most locking is already in place, the patches in this series iron out
a few bugs.

Last 5 patches are fixes and cleanups to the netdev code, including
removal of doorbell pointers used only on old versions of the chip,
removal of unnecessarily defensive code and flushing xmit_more more
carefully on error paths.

Jakub Kicinski (15):
  nfp: disallow sharing mutexes on the same machine
  nfp: fail graciously when someone tries to grab global lock
  nfp: remove cpp mutex cache
  nfp: move mutex code out of nfp_cppcore.c
  nfp: document expected locking in the core
  nfp: lock area cache earlier
  nfp: correct return codes when msleep gets interrupted
  nfp: don't ignore return value of wait_event_interruptible
  nfp: fix invalid area detection
  nfp: fix nfp_cpp_read()/nfp_cpp_write() error paths
  nfp: don't use netdev_warn() before netdev is registered
  nfp: remove RX queue pointers
  nfp: flush xmit_more on error paths
  nfp: remove defensive checks around ndo_open()/ndo_close()
  nfp: disable FW on reconfiguration errors

 drivers/net/ethernet/netronome/nfp/Makefile        |   1 +
 drivers/net/ethernet/netronome/nfp/nfp_net.h       |   8 +-
 .../net/ethernet/netronome/nfp/nfp_net_common.c    |  50 +--
 .../net/ethernet/netronome/nfp/nfp_net_debugfs.c   |  15 +-
 drivers/net/ethernet/netronome/nfp/nfpcore/nfp.h   |   9 +-
 .../ethernet/netronome/nfp/nfpcore/nfp6000_pcie.c  |  29 +-
 .../ethernet/netronome/nfp/nfpcore/nfp_cppcore.c   | 467 ++++-----------------
 .../net/ethernet/netronome/nfp/nfpcore/nfp_mutex.c | 345 +++++++++++++++
 .../net/ethernet/netronome/nfp/nfpcore/nfp_nsp.c   |  12 +-
 .../ethernet/netronome/nfp/nfpcore/nfp_resource.c  |  15 +-
 10 files changed, 484 insertions(+), 467 deletions(-)
 create mode 100644 drivers/net/ethernet/netronome/nfp/nfpcore/nfp_mutex.c

-- 
2.11.0
