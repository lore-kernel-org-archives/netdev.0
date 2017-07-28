From: Ursula Braun <ubraun@linux.vnet.ibm.com>
Subject: [PATCH net-next 00/10] net/smc: get rid of unsafe_global_rkey
Date: Fri, 28 Jul 2017 13:56:12 +0200
Message-ID: <20170728115622.17247-1-ubraun@linux.vnet.ibm.com>
Cc: hch@lst.de, netdev@vger.kernel.org, linux-rdma@vger.kernel.org,
        linux-s390@vger.kernel.org, jwi@linux.vnet.ibm.com,
        schwidefsky@de.ibm.com, heiko.carstens@de.ibm.com,
        raspl@linux.vnet.ibm.com, ubraun@linux.vnet.ibm.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-001b2d01.pphosted.com ([148.163.156.1]:43677 "EHLO
        mx0a-001b2d01.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1751725AbdG1L4b (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 28 Jul 2017 07:56:31 -0400
Received: from pps.filterd (m0098396.ppops.net [127.0.0.1])
        by mx0a-001b2d01.pphosted.com (8.16.0.21/8.16.0.21) with SMTP id v6SBtTfp004533
        for <netdev@vger.kernel.org>; Fri, 28 Jul 2017 07:56:31 -0400
Received: from e06smtp13.uk.ibm.com (e06smtp13.uk.ibm.com [195.75.94.109])
        by mx0a-001b2d01.pphosted.com with ESMTP id 2c0465jaje-1
        (version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Fri, 28 Jul 2017 07:56:31 -0400
Received: from localhost
        by e06smtp13.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
        for <netdev@vger.kernel.org> from <ubraun@linux.vnet.ibm.com>;
        Fri, 28 Jul 2017 12:56:28 +0100
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dave,

The smc code uses the unsafe_global_rkey, exposing all memory for
remote reads and writes once a connection is established.
Here is now a patch series to get rid of unsafe_global_rkey usage.
Main idea is to switch to SG-logic and separate memory regions for RMBs.

Thanks, Ursula

Ursula Braun (10):
  net/smc: serialize connection creation in all cases
  net/smc: shorten local bufsize variables
  net/smc: introduce sg-logic for RMBs
  net/smc: use separate memory regions for RMBs
  net/smc: register RMB-related memory region
  net/smc: remove Kconfig warning
  net/smc: introduce sg-logic for send buffers
  net/smc: common functions for RMBs and send buffers
  net/smc: cleanup function __smc_buf_create()
  net/smc: synchronize buffer usage with device

 net/smc/Kconfig    |   4 -
 net/smc/af_smc.c   |  64 ++++++---
 net/smc/smc_clc.c  |  12 +-
 net/smc/smc_core.c | 388 +++++++++++++++++++++++++++++------------------------
 net/smc/smc_core.h |  31 +++--
 net/smc/smc_ib.c   | 128 +++++++++++++++---
 net/smc/smc_ib.h   |  19 ++-
 net/smc/smc_rx.c   |   3 +
 net/smc/smc_tx.c   |   9 +-
 net/smc/smc_wr.c   |  63 +++++++++
 net/smc/smc_wr.h   |   1 +
 11 files changed, 477 insertions(+), 245 deletions(-)

-- 
2.11.2
