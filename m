From: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Subject: [PATCH net 0/3] RDS: TCP: socket locking RDS packet assembly fixes
Date: Sat,  4 Jun 2016 13:59:57 -0700
Message-ID: <cover.1465071319.git.sowmini.varadhan@oracle.com>
Cc: davem@davemloft.net, rds-devel@oss.oracle.com,
	ajaykumar.hotchandani@oracle.com, santosh.shilimkar@oracle.com,
	sowmini.varadhan@oracle.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:41924 "EHLO
	userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750896AbcFDVAy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 4 Jun 2016 17:00:54 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This three part patchset fixes bugs in synchronization between
rds_tcp_accept_one() and the rds-tcp send/recv path.

Patch 1 ensures that the lock_sock() is taken appropriately
and the RDS datagram reassembly state is reset  to synchronize
with the receive path.

Patch 2 ensures that partially sent RDS datagrams will get
retransmitted after rds_tcp_accept_one() switches sockets.

Patch 3 fixes a race window which would prematurely re-enable
rds_send_xmit() before the rds_tcp_connection setup has been
completed in rds_tcp_accept_one().

Sowmini Varadhan (3):
  RDS: TCP: Add/use rds_tcp_reset_callbacks to reset tcp socket safely
  RDS: TCP: Retransmit half-sent datagrams when switching sockets in
    rds_tcp_reset_callbacks
  RDS: TCP: fix race windows in send-path quiescence by
    rds_tcp_accept_one()

 net/rds/rds.h         |    2 +
 net/rds/send.c        |    1 +
 net/rds/tcp.c         |   78 +++++++++++++++++++++++++++++++++++++++++++++++--
 net/rds/tcp.h         |    1 +
 net/rds/tcp_connect.c |    2 +-
 net/rds/tcp_listen.c  |   20 ++++--------
 net/rds/threads.c     |   10 +++++-
 7 files changed, 95 insertions(+), 19 deletions(-)
