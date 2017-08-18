From: Julian Wiedmann <jwi@linux.vnet.ibm.com>
Subject: [PATCH net-next 0/7] s390/net: more updates for 4.14
Date: Fri, 18 Aug 2017 10:19:03 +0200
Message-ID: <20170818081910.48869-1-jwi@linux.vnet.ibm.com>
Cc: <netdev@vger.kernel.org>, <linux-s390@vger.kernel.org>,
        Martin Schwidefsky <schwidefsky@de.ibm.com>,
        Heiko Carstens <heiko.carstens@de.ibm.com>,
        Stefan Raspl <raspl@linux.vnet.ibm.com>,
        Ursula Braun <ubraun@linux.vnet.ibm.com>,
        Julian Wiedmann <jwi@linux.vnet.ibm.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-001b2d01.pphosted.com ([148.163.156.1]:37616 "EHLO
        mx0a-001b2d01.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1750775AbdHRITW (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 18 Aug 2017 04:19:22 -0400
Received: from pps.filterd (m0098409.ppops.net [127.0.0.1])
        by mx0a-001b2d01.pphosted.com (8.16.0.21/8.16.0.21) with SMTP id v7I8JI8A015002
        for <netdev@vger.kernel.org>; Fri, 18 Aug 2017 04:19:22 -0400
Received: from e06smtp11.uk.ibm.com (e06smtp11.uk.ibm.com [195.75.94.107])
        by mx0a-001b2d01.pphosted.com with ESMTP id 2cdmkdr6wr-1
        (version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Fri, 18 Aug 2017 04:19:21 -0400
Received: from localhost
        by e06smtp11.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
        for <netdev@vger.kernel.org> from <jwi@linux.vnet.ibm.com>;
        Fri, 18 Aug 2017 09:19:19 +0100
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave,

please apply another batch of qeth patches for net-next.
This reworks the xmit path for L2 OSAs to use skb_cow_head() instead of
skb_realloc_headroom().

Thanks,
Julian

Julian Wiedmann (7):
  s390/qeth: split L2 xmit paths
  s390/qeth: pass full data length to l2_fill_header()
  s390/qeth: pass TSO header length to fill_buffer()
  s390/qeth: pass TSO data offset to fill_buffer()
  s390/qeth: pass full IQD header length to fill_buffer()
  s390/qeth: unify code to build header elements
  s390/qeth: use skb_cow_head() for L2 OSA xmit

 drivers/s390/net/qeth_core.h      |   8 +-
 drivers/s390/net/qeth_core_main.c |  78 +++++++-----
 drivers/s390/net/qeth_l2_main.c   | 243 ++++++++++++++++++++++----------------
 drivers/s390/net/qeth_l3_main.c   |  18 +--
 4 files changed, 206 insertions(+), 141 deletions(-)

-- 
2.11.2
