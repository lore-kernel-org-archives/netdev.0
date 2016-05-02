From: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Subject: [PATCH net v2 0/2] RDS: TCP: sychronization during connection startup
Date: Mon,  2 May 2016 11:24:50 -0700
Message-ID: <cover.1462212462.git.sowmini.varadhan@oracle.com>
Cc: santosh.shilimkar@oracle.com, davem@davemloft.net
To: sowmini.varadhan@oracle.com, netdev@vger.kernel.org,
	rds-devel@oss.oracle.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:46164 "EHLO
	userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754849AbcEBSZD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 May 2016 14:25:03 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch series ensures that the passive (accept) side of the
TCP connection used for RDS-TCP is correctly synchronized with
any concurrent active (connect) attempts for a given pair of peers.

Patch 1 in the series makes sure that the t_sock in struct 
rds_tcp_connection is only reset after any threads in rds_tcp_xmit
have completed (otherwise a null-ptr deref may be encountered). 
Patch 2 synchronizes rds_tcp_accept_one() with the rds_tcp*connect()
path.

v2: review comments from Santosh Shilimkar, other spelling corrections

Sowmini Varadhan (2):
  RDS:TCP: Synchronize rds_tcp_accept_one with rds_send_xmit when
    resetting t_sock
  RDS: TCP: Synchronize accept() and connect() paths on t_conn_lock.

 net/rds/tcp.c         |    3 +-
 net/rds/tcp.h         |    4 +++
 net/rds/tcp_connect.c |    8 +++++++
 net/rds/tcp_listen.c  |   54 ++++++++++++++++++++++++++++++++----------------
 4 files changed, 50 insertions(+), 19 deletions(-)
