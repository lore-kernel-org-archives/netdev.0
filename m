From: Gavin Shan <gwshan@linux.vnet.ibm.com>
Subject: [PATCH net 0/5] net/ncsi: More bug fixes
Date: Fri, 14 Oct 2016 13:53:29 +1100
Message-ID: <1476413614-24586-1-git-send-email-gwshan@linux.vnet.ibm.com>
Cc: davem@davemloft.net, joel@jms.id.au,
        Gavin Shan <gwshan@linux.vnet.ibm.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-001b2d01.pphosted.com ([148.163.156.1]:52645 "EHLO
        mx0a-001b2d01.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1751437AbcJNCyo (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 13 Oct 2016 22:54:44 -0400
Received: from pps.filterd (m0098394.ppops.net [127.0.0.1])
        by mx0a-001b2d01.pphosted.com (8.16.0.17/8.16.0.17) with SMTP id u9E2nMwn013314
        for <netdev@vger.kernel.org>; Thu, 13 Oct 2016 22:53:02 -0400
Received: from e23smtp05.au.ibm.com (e23smtp05.au.ibm.com [202.81.31.147])
        by mx0a-001b2d01.pphosted.com with ESMTP id 262f43gncn-1
        (version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Thu, 13 Oct 2016 22:53:02 -0400
Received: from localhost
        by e23smtp05.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
        for <netdev@vger.kernel.org> from <gwshan@linux.vnet.ibm.com>;
        Fri, 14 Oct 2016 12:53:00 +1000
Received: from d23relay08.au.ibm.com (d23relay08.au.ibm.com [9.185.71.33])
        by d23dlp02.au.ibm.com (Postfix) with ESMTP id B299D2BB005A
        for <netdev@vger.kernel.org>; Fri, 14 Oct 2016 13:52:56 +1100 (EST)
Received: from d23av01.au.ibm.com (d23av01.au.ibm.com [9.190.234.96])
        by d23relay08.au.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id u9E2quwG18284664
        for <netdev@vger.kernel.org>; Fri, 14 Oct 2016 13:52:56 +1100
Received: from d23av01.au.ibm.com (localhost [127.0.0.1])
        by d23av01.au.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id u9E2qumt027277
        for <netdev@vger.kernel.org>; Fri, 14 Oct 2016 13:52:56 +1100
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series fixes 2 issues that were found during NCSI's availability
testing on BCM5718 and improves HNCDSC AEN handler:

   * PATCH[1] and PATCH[2] refactors the code so that minimal code
     change is put to PATCH[3].
   * PATCH[3] fixes the NCSI channel's stale link state before doing
     failover.
   * PATCH[4] chooses the hot channel, which was ever chosen as active
     channel, when the available channels are all in link-down state.
   * PATCH[5] improves Host Network Controller Driver Status Change
     (HNCDSC) AEN handler

Gavin Shan (5):
  net/ncsi: Not fetch active package and channel again
  net/ncsi: Split out logic for ncsi_dev_state_suspend_select
  net/ncsi: Fix stale link state of inactive channels on failover
  net/ncsi: Choose hot channel as active one if necessary
  net/ncsi: Improve HNCDSC AEN handler

 net/ncsi/internal.h    |  2 ++
 net/ncsi/ncsi-aen.c    | 18 ++++++++++--
 net/ncsi/ncsi-manage.c | 80 ++++++++++++++++++++++++++++++++++++++------------
 3 files changed, 79 insertions(+), 21 deletions(-)

-- 
2.1.0
