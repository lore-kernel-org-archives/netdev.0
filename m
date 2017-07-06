From: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Subject: [PATCH net 0/2] rds-tcp: sock_graft() leak
Date: Thu,  6 Jul 2017 08:15:05 -0700
Message-ID: <cover.1499352757.git.sowmini.varadhan@oracle.com>
Cc: davem@davemloft.net, sowmini.varadhan@oracle.com,
        santosh.shilimkar@oracle.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:45625 "EHLO
        userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751797AbdGFPR6 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 6 Jul 2017 11:17:58 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Following up on the discussion at
  https://www.spinics.net/lists/netdev/msg442859.html
- make rds_tcp_accept_one() call sock_create_lite()
- add a WARN_ON() to sock_graft() 

Tested by running an infinite while() loop that does
(module-load; rds-stress; module-unload) and monitors
TCP slabinfo while the test is running.

Sowmini Varadhan (2):
  rds: tcp: use sock_create_lite() to create the accept socket
  net/sock: add WARN_ON(parent->sk) in sock_graft()

 include/net/sock.h   |    1 +
 net/rds/tcp_listen.c |    2 +-
 2 files changed, 2 insertions(+), 1 deletions(-)
