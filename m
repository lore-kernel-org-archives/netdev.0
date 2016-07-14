From: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Subject: [PATCH net-next 0/5] RDS: TCP: Enable mprds for rds-tcp
Date: Thu, 14 Jul 2016 03:51:00 -0700
Message-ID: <cover.1468488884.git.sowmini.varadhan@oracle.com>
Cc: davem@davemloft.net, rds-devel@oss.oracle.com,
	sowmini.varadhan@oracle.com, santosh.shilimkar@oracle.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:34086 "EHLO
	userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750916AbcGNKvZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Jul 2016 06:51:25 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


The third, and final, installment for mprds-tcp changes.

In Patch 3 of this set, if the transport support t_mp_capable, 
we hash outgoing traffic across multiple paths.  Additionally, even if 
the transport is MP capable, we may be peering with some node that does
not support mprds, or supports a different number of paths. This
necessitates RDS control plane changes so that both peers agree
on the number of paths to be used for the rds-tcp connection.
Patch 3 implements all these changes, which are documented in patch 5
of the series.

Patch 1 of this series is a bug fix for a race-condition
that has always existed, but is now more easily encountered with mprds. 
Patch 2 is code refactoring. Patches 4 and 5 are Documentation updates.

Sowmini Varadhan (5):
  RDS: TCP: avoid bad page reference in rds_tcp_listen_data_ready
  RDS: TCP: Reduce code duplication in rds_tcp_reset_callbacks()
  RDS: TCP: Enable multipath RDS for TCP
  Documentation: RDS: updates for SO_RDS_TRANSPORT socket option
  Documentation: RDS: Document Multipath RDS (mprds)

 Documentation/networking/rds.txt |   72 ++++++++++++++++++++++++++++++++++++-
 net/rds/bind.c                   |    6 +++
 net/rds/connection.c             |   17 ++++-----
 net/rds/message.c                |    1 +
 net/rds/rds.h                    |   25 ++++++++++++-
 net/rds/recv.c                   |   75 ++++++++++++++++++++++++++++++++++++++
 net/rds/send.c                   |   71 ++++++++++++++++++++++++++++++++++--
 net/rds/tcp.c                    |   31 ++++++----------
 net/rds/tcp.h                    |    1 +
 net/rds/tcp_connect.c            |    7 +++-
 net/rds/tcp_listen.c             |   65 +++++++++++++++++++++++++++++----
 net/rds/tcp_send.c               |   18 +++++++---
 net/rds/threads.c                |    2 +
 13 files changed, 342 insertions(+), 49 deletions(-)
