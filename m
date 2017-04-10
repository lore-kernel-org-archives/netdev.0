From: Ursula Braun <ubraun@linux.vnet.ibm.com>
Subject: [PATCH net-next 00/10] net/smc: patches for net-next
Date: Mon, 10 Apr 2017 14:57:55 +0200
Message-ID: <20170410125805.13653-1-ubraun@linux.vnet.ibm.com>
Cc: netdev@vger.kernel.org, linux-s390@vger.kernel.org,
        jwi@linux.vnet.ibm.com, schwidefsky@de.ibm.com,
        heiko.carstens@de.ibm.com, raspl@linux.vnet.ibm.com,
        ubraun@linux.vnet.ibm.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-001b2d01.pphosted.com ([148.163.158.5]:50181 "EHLO
        mx0a-001b2d01.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1753184AbdDJM6Q (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 10 Apr 2017 08:58:16 -0400
Received: from pps.filterd (m0098421.ppops.net [127.0.0.1])
        by mx0a-001b2d01.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v3ACsXOF051525
        for <netdev@vger.kernel.org>; Mon, 10 Apr 2017 08:58:16 -0400
Received: from e06smtp12.uk.ibm.com (e06smtp12.uk.ibm.com [195.75.94.108])
        by mx0a-001b2d01.pphosted.com with ESMTP id 29r4f01qfe-1
        (version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Mon, 10 Apr 2017 08:58:15 -0400
Received: from localhost
        by e06smtp12.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
        for <netdev@vger.kernel.org> from <ubraun@linux.vnet.ibm.com>;
        Mon, 10 Apr 2017 13:58:14 +0100
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave,

here are some patches for net/smc. Most important are
improvements for socket closing.

Thanks, Ursula

Ursula Braun (10):
  net/smc: get rid of old comment
  net/smc: remove useless smc_ib_devices_list check
  net/smc: return active RoCE port only
  net/smc: guarantee reset of write_blocked for heavy workload
  net/smc: always call the POLL_IN part of sk_wake_async
  net/smc: no socket state changes in tasklet context
  net/smc: guarantee ConnClosed send after shutdown SHUT_WR
  net/smc: remove duplicate unhash
  net/smc: destruct non-accepted sockets
  net/smc: do not use IB_SEND_INLINE together with mapped data

 net/smc/af_smc.c    | 23 +++++++++++------
 net/smc/smc.h       |  1 +
 net/smc/smc_cdc.c   | 11 +++++---
 net/smc/smc_close.c | 74 +++++++++++++++++++++++++++++++++++------------------
 net/smc/smc_close.h |  2 +-
 net/smc/smc_core.c  |  2 +-
 net/smc/smc_ib.c    |  3 ---
 net/smc/smc_pnet.c  |  9 ++++---
 net/smc/smc_pnet.h  |  1 -
 net/smc/smc_rx.c    |  3 +--
 net/smc/smc_tx.c    |  6 ++++-
 net/smc/smc_wr.c    |  2 +-
 12 files changed, 87 insertions(+), 50 deletions(-)

-- 
2.10.2
