From: Gavin Shan <gwshan@linux.vnet.ibm.com>
Subject: [PATCH v2 net 0/4] net/ncsi: More bug fixes
Date: Thu, 20 Oct 2016 11:45:48 +1100
Message-ID: <1476924352-31165-1-git-send-email-gwshan@linux.vnet.ibm.com>
Cc: davem@davemloft.net, joel@jms.id.au,
        Gavin Shan <gwshan@linux.vnet.ibm.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-001b2d01.pphosted.com ([148.163.156.1]:50093 "EHLO
        mx0a-001b2d01.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S932509AbcJTApK (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 19 Oct 2016 20:45:10 -0400
Received: from pps.filterd (m0098410.ppops.net [127.0.0.1])
        by mx0a-001b2d01.pphosted.com (8.16.0.17/8.16.0.17) with SMTP id u9K0ht3e087720
        for <netdev@vger.kernel.org>; Wed, 19 Oct 2016 20:45:09 -0400
Received: from e23smtp01.au.ibm.com (e23smtp01.au.ibm.com [202.81.31.143])
        by mx0a-001b2d01.pphosted.com with ESMTP id 266jjsja89-1
        (version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Wed, 19 Oct 2016 20:45:09 -0400
Received: from localhost
        by e23smtp01.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
        for <netdev@vger.kernel.org> from <gwshan@linux.vnet.ibm.com>;
        Thu, 20 Oct 2016 10:45:07 +1000
Received: from d23relay10.au.ibm.com (d23relay10.au.ibm.com [9.190.26.77])
        by d23dlp03.au.ibm.com (Postfix) with ESMTP id 6631D3578056
        for <netdev@vger.kernel.org>; Thu, 20 Oct 2016 11:45:04 +1100 (EST)
Received: from d23av02.au.ibm.com (d23av02.au.ibm.com [9.190.235.138])
        by d23relay10.au.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id u9K0j4e76226296
        for <netdev@vger.kernel.org>; Thu, 20 Oct 2016 11:45:04 +1100
Received: from d23av02.au.ibm.com (localhost [127.0.0.1])
        by d23av02.au.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id u9K0j3n1018603
        for <netdev@vger.kernel.org>; Thu, 20 Oct 2016 11:45:04 +1100
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series fixes 2 issues that were found during NCSI's availability
testing on BCM5718 and improves HNCDSC AEN handler:

   * PATCH[1] refactors the code so that minimal code change is put
     to PATCH[2].
   * PATCH[2] fixes the NCSI channel's stale link state before doing
     failover.
   * PATCH[3] chooses the hot channel, which was ever chosen as active
     channel, when the available channels are all in link-down state.
   * PATCH[4] improves Host Network Controller Driver Status Change
     (HNCDSC) AEN handler

Changelog
=========
v2:
   * Merged PATCH[v1 1/2] to PATCH[v2 1].
   * Avoid if/else statements in ncsi_suspend_channel() as Joel suggested.
   * Added comments to explain why we need retrieve last link states in
     ncsi_suspend_channel().

Gavin Shan (4):
  net/ncsi: Avoid if statements in ncsi_suspend_channel()
  net/ncsi: Fix stale link state of inactive channels on failover
  net/ncsi: Choose hot channel as active one if necessary
  net/ncsi: Improve HNCDSC AEN handler

 net/ncsi/internal.h    |   2 +
 net/ncsi/ncsi-aen.c    |  18 +++++--
 net/ncsi/ncsi-manage.c | 126 +++++++++++++++++++++++++++++++++++++------------
 3 files changed, 112 insertions(+), 34 deletions(-)

-- 
2.1.0
