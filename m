From: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Subject: [PATCH net-next 0/9] RDS:TCP data structure changes for multipath support
Date: Thu, 30 Jun 2016 16:11:09 -0700
Message-ID: <cover.1467322344.git.sowmini.varadhan@oracle.com>
Cc: davem@davemloft.net, rds-devel@oss.oracle.com,
	sowmini.varadhan@oracle.com, santosh.shilimkar@oracle.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from aserp1050.oracle.com ([141.146.126.70]:44435 "EHLO
	aserp1050.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752558AbcF3XMU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 Jun 2016 19:12:20 -0400
Received: from aserp1040.oracle.com (aserp1040.oracle.com [141.146.126.69])
	by aserp1050.oracle.com (Sentrion-MTA-4.3.2/Sentrion-MTA-4.3.2) with ESMTP id u5UNC5tR007256
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK)
	for <netdev@vger.kernel.org>; Thu, 30 Jun 2016 23:12:05 GMT
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The second installment of changes to enable multipath support in
RDS-TCP. This series implements the changes in rds-tcp so that the 
rds_conn_path has a pointer to the rds_tcp_connection in cp_transport_data.
Struct rds_tcp_connection keeps track of the inet_sk per path in
t_sock. The ->sk_user_data in turn is a pointer to the rds_conn_path.
With this set of changes, rds_tcp has the needed plumbing to handle
multiple paths(socket) per rds_connection.

Sowmini Varadhan (9):
  RDS: Rework path specific indirections
  RDS: TCP: Remove dead logic around c_passive in rds-tcp
  RDS: TCP: Make rds_tcp_connection track the rds_conn_path
  RDS: TCP: Refactor connection destruction to handle multiple paths
  RDS: TCP: make ->sk_user_data point to a rds_conn_path
  RDS: TCP: make receive path use the rds_conn_path
  RDS: TCP: Hooks to set up a single connection path
  RDS: TCP: Simplify reconnect to avoid duelling reconnnect attempts
  RDS: Do not send a pong to an incoming ping with 0 src port

 net/rds/connection.c  |   39 ++++++--------
 net/rds/ib.c          |    8 ++--
 net/rds/ib.h          |    8 ++--
 net/rds/ib_cm.c       |    6 ++-
 net/rds/ib_recv.c     |    3 +-
 net/rds/ib_send.c     |    3 +-
 net/rds/loop.c        |   14 +++---
 net/rds/rds.h         |    7 +--
 net/rds/recv.c        |    4 ++
 net/rds/send.c        |   16 ++-----
 net/rds/tcp.c         |  130 +++++++++++++++++++++++++++++++------------------
 net/rds/tcp.h         |   22 ++++----
 net/rds/tcp_connect.c |   38 ++++++++-------
 net/rds/tcp_listen.c  |   16 +++---
 net/rds/tcp_recv.c    |   39 ++++++++-------
 net/rds/tcp_send.c    |   20 ++++----
 net/rds/threads.c     |   12 +++-
 17 files changed, 211 insertions(+), 174 deletions(-)
