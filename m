From: Robert Shearman <rshearma@brocade.com>
Subject: [PATCH net-next 0/3] l3mdev: Improve use with main table
Date: Mon, 10 Apr 2017 15:21:59 +0100
Message-ID: <1491834122-26252-1-git-send-email-rshearma@brocade.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, David Ahern <dsa@cumulusnetworks.com>,
        "Robert Shearman" <rshearma@brocade.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-000f0801.pphosted.com ([67.231.144.122]:45918 "EHLO
        mx0a-000f0801.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1753165AbdDJOW0 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 10 Apr 2017 10:22:26 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Attempting to create a TCP socket not bound to a VRF device when a TCP
socket bound to a VRF device with the same port exists (and vice
versa) fails with EADDRINUSE. This limits the ability to use programs
in selected mixed VRF/non-VRF contexts.

This patch series solves the problem by extending the l3mdev be aware
of the special semantics of the main table and fixing issues arising
from the split local/main tables. A VRF master device created linking
to the main table and used for these programs in the same way as those
created for VRF tables can.

Robert Shearman (3):
  ipv6: Fix route handling when using l3mdev set to main table
  ipv4: Fix route handling when using l3mdev set to main table
  l3mdev: Fix lookup in local table when using main table

 net/ipv4/af_inet.c      |  4 +++-
 net/ipv4/fib_frontend.c | 14 +++++++++-----
 net/ipv4/raw.c          |  5 ++++-
 net/ipv6/addrconf.c     | 12 +++++++++---
 net/ipv6/route.c        | 23 ++++++++++++++++++-----
 net/l3mdev/l3mdev.c     | 26 ++++++++++++++++++++------
 6 files changed, 63 insertions(+), 21 deletions(-)

-- 
2.1.4
