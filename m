From: Ivan Delalande <colona@arista.com>
Subject: [PATCH net-next v3 0/2] report TCP MD5 signing keys and addresses
Date: Tue, 29 Aug 2017 15:29:52 -0700
Message-ID: <20170829222954.24863-1-colona@arista.com>
Cc: Eric Dumazet <eric.dumazet@gmail.com>, netdev@vger.kernel.org,
        Ivan Delalande <colona@arista.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from prod-mx.aristanetworks.com ([162.210.130.12]:3515 "EHLO
        prod-mx.aristanetworks.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1751684AbdH2W3z (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 29 Aug 2017 18:29:55 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Allow userspace to retrieve MD5 signature keys and addresses configured
on TCP sockets through inet_diag.

Thank you Eric Dumazet for the useful explanations and feedback.

v3: - rename inet_diag_*md5sig in tcp_diag.c to tcp_diag_* for
      consistency,
    - don't lock the socket tcp_diag_put_md5sig,
    - add checks on md5sig_count in tcp_diag_put_md5sig to not create
      the netlink attribute if the list is empty, and to avoid overflows
      or memory leaks if the list has changed in the meantime.

v2: - move changes to tcp_diag.c and extend inet_diag_handler to allow
      protocols to provide additional data on INET_DIAG_INFO,
    - lock socket before calling tcp_diag_put_md5sig.


I also have a patch for iproute2/ss to test this change, making it print
this new attribute. I'm planning to polish and send it if this series
gets applied.


Ivan Delalande (2):
  inet_diag: allow protocols to provide additional data
  tcp_diag: report TCP MD5 signing keys and addresses

 include/linux/inet_diag.h      |   7 +++
 include/uapi/linux/inet_diag.h |   1 +
 net/ipv4/inet_diag.c           |  22 ++++++--
 net/ipv4/tcp_diag.c            | 115 ++++++++++++++++++++++++++++++++++++++---
 4 files changed, 135 insertions(+), 10 deletions(-)

-- 
2.14.1
