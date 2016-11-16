From: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Subject: [PATCH net-next 0/3] RDS: TCP: HA/Failover fixes
Date: Wed, 16 Nov 2016 13:29:47 -0800
Message-ID: <cover.1478876910.git.sowmini.varadhan@oracle.com>
Cc: santosh.shilimkar@oracle.com, sowmini.varadhan@oracle.com,
        davem@davemloft.net, rds-devel@oss.oracle.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:32793 "EHLO
        aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S933826AbcKPVaD (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 16 Nov 2016 16:30:03 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series contains a set of fixes for bugs exposed when
we ran the following in a loop between a test machine pair:

 while (1); do
   # modprobe rds-tcp on test nodes
   # run rds-stress in bi-dir mode between test machine pair 
   # modprobe -r rds-tcp on test nodes
 done

rds-stress in bi-dir mode will cause both nodes to initiate
RDS-TCP connections at almost the same instant, exposing the 
bugs fixed in this series. 

Without the fixes, rds-stress reports sporadic packet drops,
and packets arriving out of sequence. After the fixes,we have
been able to run the  test overnight, without any issues.

Each patch has a detailed description of the root-cause fixed
by the patch.


Sowmini Varadhan (3):
  RDS: TCP: set RDS_FLAG_RETRANSMITTED in cp_retrans list
  RDS: TCP: Track peer's connection generation number
  RDS: TCP: Force every connection to be initiated by numerically
    smaller IP address

 net/rds/af_rds.c      |    4 ++++
 net/rds/connection.c  |    3 +++
 net/rds/message.c     |    1 +
 net/rds/rds.h         |    8 +++++++-
 net/rds/recv.c        |   36 ++++++++++++++++++++++++++++++++++++
 net/rds/send.c        |    9 +++++++--
 net/rds/tcp_connect.c |   14 +++++++++++++-
 net/rds/tcp_listen.c  |   29 ++++++++++++-----------------
 net/rds/tcp_send.c    |    3 +++
 9 files changed, 86 insertions(+), 21 deletions(-)
