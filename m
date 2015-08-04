From: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Subject: [PATCH v2 net-next 0/2] RDS-TCP: Network namespace support
Date: Tue,  4 Aug 2015 01:29:11 -0400
Message-ID: <cover.1438612466.git.sowmini.varadhan@oracle.com>
Cc: davem@davemloft.net, rds-devel@oss.oracle.com,
	ajaykumar.hotchandani@oracle.com, igor.maximov@oracle.com,
	chien.yen@oracle.com, sowmini.varadhan@oracle.com
To: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch series contains the set of changes to correctly set up 
the infra for PF_RDS sockets that use TCP as the transport in multiple
network namespaces.

Patch 1 in the series is the minimal set of changes to allow
a single instance of RDS-TCP to run in any (i.e init_net or other) net
namespace.  The changes in this patch set ensure that the execution of 
'modprobe [-r] rds_tcp' sets up the kernel TCP sockets 
relative to the current netns, so that RDS applications can send/recv
packets from that netns, and the netns can later be deleted cleanly.

Patch 2 of the series further allows multiple RDS-TCP instances,
one per network namespace. The changes in this patch allows dynamic
creation/tear-down of RDS-TCP client and server sockets  across all
current and future namespaces. 

v2 changes from RFC sent out earlier:
    David Ahern comments in patch 1, net_device notifier in patch 2, 
    patch 3 broken off and submitted separately.

Sowmini Varadhan (2):
  Make RDS-TCP work correctly when it is set up in a netns other than
    init_net
  Support multiple RDS-TCP listen endpoints, one per netns.

 net/rds/bind.c        |    3 +-
 net/rds/connection.c  |   16 +++--
 net/rds/ib.c          |    2 +-
 net/rds/ib_cm.c       |    5 +-
 net/rds/iw.c          |    2 +-
 net/rds/iw_cm.c       |    5 +-
 net/rds/rds.h         |   23 ++++++-
 net/rds/send.c        |    3 +-
 net/rds/tcp.c         |  167 +++++++++++++++++++++++++++++++++++++++++++-----
 net/rds/tcp.h         |    7 ++-
 net/rds/tcp_connect.c |    9 ++-
 net/rds/tcp_listen.c  |   40 ++++--------
 net/rds/transport.c   |    4 +-
 13 files changed, 216 insertions(+), 70 deletions(-)
