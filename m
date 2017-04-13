From: Gavin Shan <gwshan@linux.vnet.ibm.com>
Subject: [PATCH net-next 0/8] net/ncsi: Add debugging functionality
Date: Thu, 13 Apr 2017 12:46:32 +1000
Message-ID: <1492051600-26706-1-git-send-email-gwshan@linux.vnet.ibm.com>
Cc: davem@davemloft.net, Gavin Shan <gwshan@linux.vnet.ibm.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-001b2d01.pphosted.com ([148.163.156.1]:56901 "EHLO
        mx0a-001b2d01.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1755989AbdDMCsp (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 12 Apr 2017 22:48:45 -0400
Received: from pps.filterd (m0098404.ppops.net [127.0.0.1])
        by mx0a-001b2d01.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v3D2j5Bm057864
        for <netdev@vger.kernel.org>; Wed, 12 Apr 2017 22:48:40 -0400
Received: from e23smtp01.au.ibm.com (e23smtp01.au.ibm.com [202.81.31.143])
        by mx0a-001b2d01.pphosted.com with ESMTP id 29srxt9fge-1
        (version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Wed, 12 Apr 2017 22:48:39 -0400
Received: from localhost
        by e23smtp01.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
        for <netdev@vger.kernel.org> from <gwshan@linux.vnet.ibm.com>;
        Thu, 13 Apr 2017 12:48:37 +1000
Received: from d23av06.au.ibm.com (d23av06.au.ibm.com [9.190.235.151])
        by d23relay10.au.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id v3D2mRHe34799620
        for <netdev@vger.kernel.org>; Thu, 13 Apr 2017 12:48:35 +1000
Received: from d23av06.au.ibm.com (localhost [127.0.0.1])
        by d23av06.au.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id v3D2m03k014886
        for <netdev@vger.kernel.org>; Thu, 13 Apr 2017 12:48:03 +1000
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series supports NCSI debugging infrastructure by adding several
procfs files. It was inspired by the reported issues: No available
package and channel are probed successfully. Obviously, we don't
have a debugging infrastructure for NCSI stack yet.

The first 3 patches, fixing some issues, aren't relevant to the
subject. I included them because I expect they can be merged beofre
the code for debugging infrastructure. PATCH[4,5,6/8] adds procfs
directories and files to support the debugging infrastructure for
several purposes: presenting the NCSI topology; statistics on sent
and received NCSI packets; generate NCSI command packet manually.
PATCH[7,8/8] fixes two issues found from the debugging functionality.

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
 net/ncsi/ncsi-debug.c  | 961 +++++++++++++++++++++++++++++++++++++++++++++++++
 net/ncsi/ncsi-manage.c |  63 +++-
 net/ncsi/ncsi-rsp.c    |  37 +-
 8 files changed, 1165 insertions(+), 12 deletions(-)
 create mode 100644 net/ncsi/ncsi-debug.c

-- 
2.7.4
