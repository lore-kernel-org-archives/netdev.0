From: Gavin Shan <gwshan@linux.vnet.ibm.com>
Subject: [PATCH net-next 0/8] net/ncsi: NCSI Improvment and bug fixes
Date: Thu, 29 Sep 2016 15:03:07 +1000
Message-ID: <1475125395-8459-1-git-send-email-gwshan@linux.vnet.ibm.com>
Cc: davem@davemloft.net, joel@jms.id.au, yuvali@mellanox.com,
        benh@kernel.crashing.org, Gavin Shan <gwshan@linux.vnet.ibm.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-001b2d01.pphosted.com ([148.163.158.5]:45460 "EHLO
        mx0a-001b2d01.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1753004AbcI2FDT (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 29 Sep 2016 01:03:19 -0400
Received: from pps.filterd (m0098421.ppops.net [127.0.0.1])
        by mx0a-001b2d01.pphosted.com (8.16.0.17/8.16.0.17) with SMTP id u8T53Iqc004039
        for <netdev@vger.kernel.org>; Thu, 29 Sep 2016 01:03:18 -0400
Received: from e23smtp06.au.ibm.com (e23smtp06.au.ibm.com [202.81.31.148])
        by mx0a-001b2d01.pphosted.com with ESMTP id 25rveh01nx-1
        (version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Thu, 29 Sep 2016 01:03:17 -0400
Received: from localhost
        by e23smtp06.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
        for <netdev@vger.kernel.org> from <gwshan@linux.vnet.ibm.com>;
        Thu, 29 Sep 2016 15:03:10 +1000
Received: from d23relay06.au.ibm.com (d23relay06.au.ibm.com [9.185.63.219])
        by d23dlp01.au.ibm.com (Postfix) with ESMTP id 486892CE805F
        for <netdev@vger.kernel.org>; Thu, 29 Sep 2016 15:03:07 +1000 (EST)
Received: from d23av04.au.ibm.com (d23av04.au.ibm.com [9.190.235.139])
        by d23relay06.au.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id u8T537AJ58261650
        for <netdev@vger.kernel.org>; Thu, 29 Sep 2016 15:03:07 +1000
Received: from d23av04.au.ibm.com (localhost [127.0.0.1])
        by d23av04.au.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id u8T536Ia016753
        for <netdev@vger.kernel.org>; Thu, 29 Sep 2016 15:03:07 +1000
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series of patches improves NCSI stack according to the comments
I received after the NCSI code was merged to 4.8.rc1:

  * PATCH[1/8] fixes the build warning caused by xchg() with ia64-linux-gcc.
    The atomic operations are replaced with {READ, WRITE}_ONCE().
  * Channel ID (0x1f) is the reserved one and it cannot be valid channel ID.
    So we needn't try to probe channel whose ID is 0x1f. PATCH[2/8] and
    PATCH[3/8] are addressing this issue.
  * The request IDs are assigned in round-robin fashion, but it's broken.
    PATCH[4/8] make it work.
  * PATCH[5/8] and PATCH[6/8] reworks the channel monitoring to improve the
    code readability and its robustness.
  * PATCH[7/8] and PATCH[8/8] introduces ncsi_stop_dev() so that the network
    device can be closed and opened afterwards. No error will be seen.

Gavin Shan (8):
  net/ncsi: Avoid unused-value build warning from ia64-linux-gcc
  net/ncsi: Introduce NCSI_RESERVED_CHANNEL
  net/ncsi: Don't probe on the reserved channel ID (0x1f)
  net/ncsi: Rework request index allocation
  net/ncsi: Allow to extend NCSI request properties
  net/ncsi: Rework the channel monitoring
  net/ncsi: Introduce ncsi_stop_dev()
  net/faraday: Stop NCSI device on shutdown

 drivers/net/ethernet/faraday/ftgmac100.c |   2 +
 include/net/ncsi.h                       |   5 +
 net/ncsi/internal.h                      |  22 ++--
 net/ncsi/ncsi-aen.c                      |  19 ++--
 net/ncsi/ncsi-cmd.c                      |   2 +-
 net/ncsi/ncsi-manage.c                   | 166 ++++++++++++++++++-------------
 net/ncsi/ncsi-rsp.c                      |  17 +---
 7 files changed, 137 insertions(+), 96 deletions(-)

-- 
2.1.0
