From: Tom Herbert <tom@herbertland.com>
Subject: [PATCH net-next 0/3] strp: Generalize stream parser to work with other socket types
Date: Sun, 28 Aug 2016 14:43:16 -0700
Message-ID: <1472420599-510735-1-git-send-email-tom@herbertland.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <kernel-team@fb.com>, <davejwatson@fb.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-00082601.pphosted.com ([67.231.153.30]:51380 "EHLO
        mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1751041AbcH1Vne (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 28 Aug 2016 17:43:34 -0400
Received: from pps.filterd (m0001255.ppops.net [127.0.0.1])
        by mx0b-00082601.pphosted.com (8.16.0.17/8.16.0.17) with SMTP id u7SLfwrI017068
        for <netdev@vger.kernel.org>; Sun, 28 Aug 2016 14:43:33 -0700
Received: from mail.thefacebook.com ([199.201.64.23])
        by mx0b-00082601.pphosted.com with ESMTP id 2536p3mvg6-1
        (version=TLSv1 cipher=ECDHE-RSA-AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Sun, 28 Aug 2016 14:43:33 -0700
Received: from facebook.com (2401:db00:21:6030:face:0:92:0)     by
 mx-out.facebook.com (10.102.107.99) with ESMTP id
 769cde0a6d6811e6b5000002c99293a0-e84f9aa0 for <netdev@vger.kernel.org>;        Sun,
 28 Aug 2016 14:43:31 -0700
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add a read_sock protocol operation function that allows something like
tcp_read_sock to be called for other protocol types.

Specific changes in this patch set:
  - Add read_sock function to proto_ops. This has the same signature as
    tcp_read_sock. sk_read_actor_t is also defined in net.h.
  - Set peek_len and read_sock proto_op functions for TCPv4 and TCPv6
    stream ops.
  - Remove references to tcp in strparser.
  - Call peek_len and read_sock operations from strparser instead of
    calling TCP specific functions.

Tom Herbert (3):
  net: Add read_sock proto_op
  tcp: Set read_sock and peek_len proto_ops
  kcm: Remove TCP specific references from kcm and strparser

 include/linux/net.h       |  6 ++++++
 include/net/strparser.h   |  2 +-
 include/net/tcp.h         |  4 ++--
 net/ipv4/af_inet.c        |  2 ++
 net/ipv4/tcp.c            |  6 ++++++
 net/ipv6/af_inet6.c       |  2 ++
 net/kcm/kcmsock.c         | 30 +++++++++++++----------------
 net/strparser/strparser.c | 48 ++++++++++++++++++++++++++++-------------------
 8 files changed, 61 insertions(+), 39 deletions(-)

-- 
2.8.0.rc2
