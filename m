From: Gavin Shan <gwshan@linux.vnet.ibm.com>
Subject: [PATCH v2 net-next 0/8] net/ncsi: Add debugging functionality
Date: Thu, 13 Apr 2017 17:48:13 +1000
Message-ID: <1492069701-20772-1-git-send-email-gwshan@linux.vnet.ibm.com>
Cc: joe@perches.com, davem@davemloft.net,
        Gavin Shan <gwshan@linux.vnet.ibm.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-001b2d01.pphosted.com ([148.163.158.5]:49977 "EHLO
        mx0a-001b2d01.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1756239AbdDMHtd (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 13 Apr 2017 03:49:33 -0400
Received: from pps.filterd (m0098414.ppops.net [127.0.0.1])
        by mx0b-001b2d01.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v3D7nRp7091478
        for <netdev@vger.kernel.org>; Thu, 13 Apr 2017 03:49:32 -0400
Received: from e23smtp05.au.ibm.com (e23smtp05.au.ibm.com [202.81.31.147])
        by mx0b-001b2d01.pphosted.com with ESMTP id 29t32qd0rh-1
        (version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Thu, 13 Apr 2017 03:49:31 -0400
Received: from localhost
        by e23smtp05.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
        for <netdev@vger.kernel.org> from <gwshan@linux.vnet.ibm.com>;
        Thu, 13 Apr 2017 17:49:26 +1000
Received: from d23av03.au.ibm.com (d23av03.au.ibm.com [9.190.234.97])
        by d23relay06.au.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id v3D7nFxa50266222
        for <netdev@vger.kernel.org>; Thu, 13 Apr 2017 17:49:23 +1000
Received: from d23av03.au.ibm.com (localhost [127.0.0.1])
        by d23av03.au.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id v3D7mlnl022506
        for <netdev@vger.kernel.org>; Thu, 13 Apr 2017 17:48:47 +1000
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series supports NCSI debugging infrastructure by adding several
debugfs files. It was inspired by the reported issues: No available
package and channel are probed successfully. Obviously, we don't
have a debugging infrastructure for NCSI stack yet.

The first 3 patches, fixing some issues, aren't relevant to the
subject. I included them because I expect they can be merged beofre
the code for debugging infrastructure. PATCH[4,5,6/8] adds debugfs 
directories and files to support the debugging infrastructure for
several purposes: presenting the NCSI topology; statistics on sent
and received NCSI packets; generate NCSI command packet manually.
PATCH[7,8/8] fixes two issues found from the debugging functionality.

Changelog
=========
v2:
   * Use debugfs instead of procfs (Joe Perches).

Gavin Shan (8):
  net/ncsi: Disable HWA mode when no channels are found
  net/ncsi: Properly track channel monitor timer state
  net/ncsi: Enforce failover on link monitor timeout
  net/ncsi: Add debugging infrastructurre
  net/ncsi: Dump NCSI packet statistics
  net/ncsi: Support NCSI packet generation
  net/ncsi: No error report on DP response to non-existing package
  net/ncsi: Fix length of GVI response packet

 net/ncsi/Kconfig       |   9 +
 net/ncsi/Makefile      |   1 +
 net/ncsi/internal.h    |  68 ++++
 net/ncsi/ncsi-aen.c    |  15 +-
 net/ncsi/ncsi-cmd.c    |  23 +-
 net/ncsi/ncsi-debug.c  | 962 +++++++++++++++++++++++++++++++++++++++++++++++++
 net/ncsi/ncsi-manage.c |  63 +++-
 net/ncsi/ncsi-rsp.c    |  37 +-
 8 files changed, 1166 insertions(+), 12 deletions(-)
 create mode 100644 net/ncsi/ncsi-debug.c

-- 
2.7.4
