From: Gavin Shan <gwshan@linux.vnet.ibm.com>
Subject: [PATCH v4 net-next 00/10] net/ncsi: Add debugging functionality
Date: Wed,  3 May 2017 14:44:31 +1000
Message-ID: <1493786681-27468-1-git-send-email-gwshan@linux.vnet.ibm.com>
Cc: joe@perches.com, kubakici@wp.pl, f.fainelli@gmail.com,
        davem@davemloft.net, Gavin Shan <gwshan@linux.vnet.ibm.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-001b2d01.pphosted.com ([148.163.158.5]:41031 "EHLO
        mx0a-001b2d01.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1751014AbdECEpr (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 3 May 2017 00:45:47 -0400
Received: from pps.filterd (m0098420.ppops.net [127.0.0.1])
        by mx0b-001b2d01.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v434huBO074880
        for <netdev@vger.kernel.org>; Wed, 3 May 2017 00:45:46 -0400
Received: from e23smtp01.au.ibm.com (e23smtp01.au.ibm.com [202.81.31.143])
        by mx0b-001b2d01.pphosted.com with ESMTP id 2a752a6xnc-1
        (version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Wed, 03 May 2017 00:45:46 -0400
Received: from localhost
        by e23smtp01.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
        for <netdev@vger.kernel.org> from <gwshan@linux.vnet.ibm.com>;
        Wed, 3 May 2017 14:45:43 +1000
Received: from d23av04.au.ibm.com (d23av04.au.ibm.com [9.190.235.139])
        by d23relay08.au.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id v434jXKV4391296
        for <netdev@vger.kernel.org>; Wed, 3 May 2017 14:45:41 +1000
Received: from d23av04.au.ibm.com (localhost [127.0.0.1])
        by d23av04.au.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id v434j7HQ003051
        for <netdev@vger.kernel.org>; Wed, 3 May 2017 14:45:08 +1000
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series supports NCSI debugging infrastructure by adding several
ethtool commands and one debugfs file. It was inspired by the reported
issues: No available package and channel are probed successfully.
Obviously, we don't have a debugging infrastructure for NCSI stack yet.

The first 3 patches, fixing some issues, aren't relevant to the
subject. I included them because I expect they can be merged beofre
the code for debugging infrastructure. PATCH[4,5,6,7] adds ethtool
commands to dump NCSI topology, channel information, HW statistics
and SW statistics. PATCH[8] adds debugfs entry /sys/kernel/debug/
ncsi/eth0/pkt, which sends NCSI command packet on write. The NCSI
response packet are dumped on read. PATCH[9,10] fix two issues
found by the debugging functionality.

Changelog
=========
v4:
   * Replace debugfs entries with ethtool commands                   (Dave)
   * Add ethtool commands to dump NCSI topology, channel info and
     HW statistics                                                   (Gavin)
v3:
   * Use pr_debug() instead of pr_warn() upon failure to create
     debugfs directory or file                                       (Joe Perches)
   * Use relative debugfs path/file names in debug messages in
     ncsi-debug.c                                                    (Joe Perches)
   * Use const specifier for @ncsi_pkt_handlers and @ranges          (Joe Perches)
   * Eliminate CONFIG_NET_NCSI_DEBUG ifdef's in *.c                  (Jakub Kicinski)
v2:
   * Use debugfs instead of procfs                                   (Joe Perches)

Gavin Shan (10):
  net/ncsi: Disable HWA mode when no channels are found
  net/ncsi: Properly track channel monitor timer state
  net/ncsi: Enforce failover on link monitor timeout
  net/ncsi: Ethtool operation to get NCSI topology
  net/ncsi: Ethtool operation to get NCSI channel info
  net/ncsi: Ethtool operation to get NCSI hw statistics
  net/ncsi: Ethtool operation to get NCSI sw statistics
  net/ncsi: Support NCSI packet generation
  net/ncsi: No error report on DP response to non-existing package
  net/ncsi: Fix length of GVI response packet

 include/linux/ethtool.h      |   8 +
 include/uapi/linux/ethtool.h | 312 ++++++++++++++++++
 net/core/ethtool.c           | 120 +++++++
 net/ncsi/Kconfig             |   9 +
 net/ncsi/Makefile            |   4 +-
 net/ncsi/internal.h          |  71 ++++
 net/ncsi/ncsi-aen.c          |  14 +-
 net/ncsi/ncsi-cmd.c          |  13 +-
 net/ncsi/ncsi-debug.c        | 759 +++++++++++++++++++++++++++++++++++++++++++
 net/ncsi/ncsi-ethtool.c      | 321 ++++++++++++++++++
 net/ncsi/ncsi-manage.c       |  56 +++-
 net/ncsi/ncsi-rsp.c          |  34 +-
 12 files changed, 1708 insertions(+), 13 deletions(-)
 create mode 100644 net/ncsi/ncsi-debug.c
 create mode 100644 net/ncsi/ncsi-ethtool.c

-- 
2.7.4
