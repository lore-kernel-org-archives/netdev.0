From: Andy Grover <andy.grover@oracle.com>
Subject: [ofa-general] [PATCH 0/26] Reliable Datagram Sockets (RDS), take 2
Date: Tue, 24 Feb 2009 17:30:17 -0800
Message-ID: <1235525443-9007-1-git-send-email-andy.grover@oracle.com>
Cc: rds-devel@oss.oracle.com, general@lists.openfabrics.org
To: netdev@vger.kernel.org
Return-path: <general-bounces@lists.openfabrics.org>
List-Unsubscribe: <http://lists.openfabrics.org/cgi-bin/mailman/listinfo/general>,
	<mailto:general-request@lists.openfabrics.org?subject=unsubscribe>
List-Archive: <http://lists.openfabrics.org/pipermail/general>
List-Post: <mailto:general@lists.openfabrics.org>
List-Help: <mailto:general-request@lists.openfabrics.org?subject=help>
List-Subscribe: <http://lists.openfabrics.org/cgi-bin/mailman/listinfo/general>,
	<mailto:general-request@lists.openfabrics.org?subject=subscribe>
Sender: general-bounces@lists.openfabrics.org
Errors-To: general-bounces@lists.openfabrics.org
List-Id: netdev.vger.kernel.org


Hi,

This patchset against net-next adds support for RDS sockets. RDS is an
Oracle-originated protocol used to send IPC datagrams (up to 1MB)
reliably, and is used currently in Oracle RAC and Exadata products. 

I've addressed all the issues from comments on take 1. (thanks!) This patchset
squashes the changes into the original changeset, but I've also included
a tree where the un-squashed changes since last time may be reviewed:
git://git.openfabrics.org/~agrover/ofed_1_4/linux-2.6.git
rds-broken-out-fixes

Major changes since last time include moving to net/rds, and the
additional inclusion of iwarp transport support.

shortlog for patchseries follows.

Thanks -- Regards -- Andy

Andy Grover (26):
      RDS: Socket interface
      RDS: Main header file
      RDS: Congestion-handling code
      RDS: Transport code
      RDS: Info and stats
      RDS: Connection handling
      RDS: loopback
      RDS: sysctls
      RDS: Message parsing
      RDS: send.c
      RDS: recv.c
      RDS: RDMA support
      RDS/IB: Infiniband transport
      RDS/IB: Ring-handling code.
      RDS/IB: Implement RDMA ops using FMRs
      RDS/IB: Implement IB-specific datagram send.
      RDS/IB: Receive datagrams via IB
      RDS/IB: Stats and sysctls
      RDS: Add iWARP support
      RDS: Common RDMA transport code
      RDS: Documentation
      RDS: Kconfig and Makefile
      RDS: Add AF and PF #defines for RDS sockets
      RDS: Add MAINTAINERS entry
      RDS: Add userspace header
      RDS: Add RDS to AF key strings

 Documentation/networking/rds.txt |  356 ++++++++++++++
 MAINTAINERS                      |    6 +
 include/linux/rds.h              |  250 ++++++++++
 include/linux/socket.h           |    5 +-
 net/Kconfig                      |    1 +
 net/Makefile                     |    1 +
 net/core/sock.c                  |    6 +-
 net/rds/Kconfig                  |   13 +
 net/rds/Makefile                 |   14 +
 net/rds/af_rds.c                 |  586 ++++++++++++++++++++++
 net/rds/bind.c                   |  199 ++++++++
 net/rds/cong.c                   |  402 +++++++++++++++
 net/rds/connection.c             |  487 ++++++++++++++++++
 net/rds/ib.c                     |  323 ++++++++++++
 net/rds/ib.h                     |  367 ++++++++++++++
 net/rds/ib_cm.c                  |  726 +++++++++++++++++++++++++++
 net/rds/ib_rdma.c                |  641 ++++++++++++++++++++++++
 net/rds/ib_recv.c                |  869
+++++++++++++++++++++++++++++++++
 net/rds/ib_ring.c                |  168 +++++++
 net/rds/ib_send.c                |  874
+++++++++++++++++++++++++++++++++
 net/rds/ib_stats.c               |   95 ++++
 net/rds/ib_sysctl.c              |  137 ++++++
 net/rds/info.c                   |  241 +++++++++
 net/rds/info.h                   |   30 ++
 net/rds/iw.c                     |  333 +++++++++++++
 net/rds/iw.h                     |  395 +++++++++++++++
 net/rds/iw_cm.c                  |  750 ++++++++++++++++++++++++++++
 net/rds/iw_rdma.c                |  888
+++++++++++++++++++++++++++++++++
 net/rds/iw_recv.c                |  869
+++++++++++++++++++++++++++++++++
 net/rds/iw_ring.c                |  169 +++++++
 net/rds/iw_send.c                |  975
++++++++++++++++++++++++++++++++++++
 net/rds/iw_stats.c               |   95 ++++
 net/rds/iw_sysctl.c              |  137 ++++++
 net/rds/loop.c                   |  188 +++++++
 net/rds/loop.h                   |    9 +
 net/rds/message.c                |  402 +++++++++++++++
 net/rds/page.c                   |  221 +++++++++
 net/rds/rdma.c                   |  679 ++++++++++++++++++++++++++
 net/rds/rdma.h                   |   84 ++++
 net/rds/rdma_transport.c         |  214 ++++++++
 net/rds/rdma_transport.h         |   28 +
 net/rds/rds.h                    |  686 ++++++++++++++++++++++++++
 net/rds/recv.c                   |  542 ++++++++++++++++++++
 net/rds/send.c                   | 1003
++++++++++++++++++++++++++++++++++++++
 net/rds/stats.c                  |  148 ++++++
 net/rds/sysctl.c                 |  122 +++++
 net/rds/threads.c                |  265 ++++++++++
 net/rds/transport.c              |  117 +++++
 48 files changed, 16112 insertions(+), 4 deletions(-)
 create mode 100644 Documentation/networking/rds.txt
 create mode 100644 include/linux/rds.h
 create mode 100644 net/rds/Kconfig
 create mode 100644 net/rds/Makefile
 create mode 100644 net/rds/af_rds.c
 create mode 100644 net/rds/bind.c
 create mode 100644 net/rds/cong.c
 create mode 100644 net/rds/connection.c
 create mode 100644 net/rds/ib.c
 create mode 100644 net/rds/ib.h
 create mode 100644 net/rds/ib_cm.c
 create mode 100644 net/rds/ib_rdma.c
 create mode 100644 net/rds/ib_recv.c
 create mode 100644 net/rds/ib_ring.c
 create mode 100644 net/rds/ib_send.c
 create mode 100644 net/rds/ib_stats.c
 create mode 100644 net/rds/ib_sysctl.c
 create mode 100644 net/rds/info.c
 create mode 100644 net/rds/info.h
 create mode 100644 net/rds/iw.c
 create mode 100644 net/rds/iw.h
 create mode 100644 net/rds/iw_cm.c
 create mode 100644 net/rds/iw_rdma.c
 create mode 100644 net/rds/iw_recv.c
 create mode 100644 net/rds/iw_ring.c
 create mode 100644 net/rds/iw_send.c
 create mode 100644 net/rds/iw_stats.c
 create mode 100644 net/rds/iw_sysctl.c
 create mode 100644 net/rds/loop.c
 create mode 100644 net/rds/loop.h
 create mode 100644 net/rds/message.c
 create mode 100644 net/rds/page.c
 create mode 100644 net/rds/rdma.c
 create mode 100644 net/rds/rdma.h
 create mode 100644 net/rds/rdma_transport.c
 create mode 100644 net/rds/rdma_transport.h
 create mode 100644 net/rds/rds.h
 create mode 100644 net/rds/recv.c
 create mode 100644 net/rds/send.c
 create mode 100644 net/rds/stats.c
 create mode 100644 net/rds/sysctl.c
 create mode 100644 net/rds/threads.c
 create mode 100644 net/rds/transport.c

end
