From: Ursula Braun <ubraun@linux.vnet.ibm.com>
Subject: [PATCH V2 net-next 0/3] TCP experimental option for SMC rendezvous
Date: Wed, 18 Oct 2017 16:29:57 +0200
Message-ID: <20171018143000.23884-1-ubraun@linux.vnet.ibm.com>
Cc: netdev@vger.kernel.org, linux-s390@vger.kernel.org,
        jwi@linux.vnet.ibm.com, schwidefsky@de.ibm.com,
        heiko.carstens@de.ibm.com, raspl@linux.vnet.ibm.com,
        ubraun@linux.vnet.ibm.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-001b2d01.pphosted.com ([148.163.156.1]:35530 "EHLO
        mx0a-001b2d01.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1751048AbdJROaI (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 18 Oct 2017 10:30:08 -0400
Received: from pps.filterd (m0098399.ppops.net [127.0.0.1])
        by mx0a-001b2d01.pphosted.com (8.16.0.21/8.16.0.21) with SMTP id v9IETHUa078354
        for <netdev@vger.kernel.org>; Wed, 18 Oct 2017 10:30:07 -0400
Received: from e06smtp12.uk.ibm.com (e06smtp12.uk.ibm.com [195.75.94.108])
        by mx0a-001b2d01.pphosted.com with ESMTP id 2dp5h5xdtq-1
        (version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Wed, 18 Oct 2017 10:30:07 -0400
Received: from localhost
        by e06smtp12.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
        for <netdev@vger.kernel.org> from <ubraun@linux.vnet.ibm.com>;
        Wed, 18 Oct 2017 15:30:04 +0100
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dave,

SMC-capability is to be negotiated with a TCP experimental option.
As requested during code review of our previous approach using
netfilter hooks, here's a new version. It touches tcp-code in the
first patch and exploits the new tcp flag in the smc-code.

Kind regards, Ursula

Changelog:

V2:
* switch to current jump labels API
* remove static key checking in smc_set_capability()
  (comment from Eric Dumazet)
* use inet_request_sock parameter for smc_set_option_cond()
* smc_listen_work(): replace local variable lgr_lock_taken by new labels
                     and separate this change into a prerequisite first
                     patch

Ursula Braun (3):
  smc: fix mutex unlocks during link group creation 
  tcp: TCP experimental option for SMC
  smc: add SMC rendezvous protocol

 include/linux/tcp.h      |  9 +++++--
 include/net/inet_sock.h  |  3 ++-
 include/net/tcp.h        |  8 ++++++
 net/ipv4/tcp.c           |  6 +++++
 net/ipv4/tcp_input.c     | 34 +++++++++++++++++++++++++
 net/ipv4/tcp_minisocks.c | 19 ++++++++++++++
 net/ipv4/tcp_output.c    | 66 +++++++++++++++++++++++++++++++++++++++++++++---
 net/smc/af_smc.c         | 42 ++++++++++++++++++++++--------
 8 files changed, 170 insertions(+), 17 deletions(-)

-- 
2.13.5
