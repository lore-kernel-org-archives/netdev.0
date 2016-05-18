From: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Subject: [PATCH net 0/2] RDS: TCP: connection spamming fixes
Date: Wed, 18 May 2016 10:06:22 -0700
Message-ID: <cover.1463579486.git.sowmini.varadhan@oracle.com>
Cc: davem@davemloft.net, rds-devel@oss.oracle.com,
	ajaykumar.hotchandani@oracle.com, sowmini.varadhan@oracle.com,
	santosh.shilimkar@oracle.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:38420 "EHLO
	aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751911AbcERRGy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 May 2016 13:06:54 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We have been testing the RDS-TCP code with a connection spammer
that sends incoming SYNs to the RDS listen port well after 
an rds-tcp connection has been established, and found a few 
race-windows that are fixed by this patch series.

Patch 1 avoids a null pointer deref when an incoming SYN 
shows up when a netns is being dismantled, or when the 
rds-tcp module is being unloaded. 

Patch 2 addresses the case when a SYN is received after the
connection arbitration algorithm has converged: the incoming
SYN should not needlessly quiesce the transmit path, and it
should not result in needless TCP connection resets due to
re-execution of the connection arbitration logic.

Sowmini Varadhan (2):
  RDS: TCP: rds_tcp_accept_worker() must exit gracefully when
    terminating rds-tcp
  RDS: TCP: Avoid rds connection churn from rogue SYNs

 net/rds/tcp_listen.c |   13 +++++++++----
 1 files changed, 9 insertions(+), 4 deletions(-)
