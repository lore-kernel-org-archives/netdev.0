From: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Subject: [PATCH v2 net-next 0/3]  RDS: RDS-TCP perf enhancements
Date: Wed, 30 Sep 2015 16:54:06 -0400
Message-ID: <cover.1443636587.git.sowmini.varadhan@oracle.com>
Cc: davem@davemloft.net, rds-devel@oss.oracle.com,
	ajaykumar.hotchandani@oracle.com, igor.maximov@oracle.com,
	sowmini.varadhan@oracle.com, santosh.shilimkar@oracle.com,
	sergei.shtylyov@cogentembedded.com
To: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:22400 "EHLO
	userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932980AbbI3Uyb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Sep 2015 16:54:31 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

A 3-part patchset that (a) improves current RDS-TCP perf
by 2X-3X and (b) refactors earlier robustness code for
better observability/scaling.

Patch 1 is an enhancment of earlier robustness fixes 
that had used separate sockets for client and server endpoints to
resolve race conditions. It is possible to have an equivalent
solution that does not use 2 sockets. The benefit of a
single socket solution is that it results in more predictable
and observable behavior for the underlying TCP pipe of an 
RDS connection

Patches 2 and 3 are simple, straightforward perf bug fixes
that align the RDS TCP socket with other parts of the kernel stack.

v2: fix kbuild-test-robot warnings, comments from  Sergei Shtylov
    and Santosh Shilimkar. 

Sowmini Varadhan (3):
  Use a single TCP socket for both send and receive.
  Do not bloat sndbuf/rcvbuf in rds_tcp_tune
  Set up MSG_MORE and MSG_SENDPAGE_NOTLAST as appropriate in
    rds_tcp_xmit

 net/rds/connection.c |   22 ++++++----------------
 net/rds/rds.h        |    4 +++-
 net/rds/tcp.c        |   16 ++++------------
 net/rds/tcp_listen.c |   22 +++++++++-------------
 net/rds/tcp_send.c   |    8 +++++++-
 5 files changed, 29 insertions(+), 43 deletions(-)
