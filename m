From: Octavian Purdila <opurdila@ixiacom.com>
Subject: [net-next PATCH v5 0/3] net: reserve ports for applications using fixed port numbers
Date: Fri, 19 Feb 2010 00:30:08 +0200
Message-ID: <1266532210-11536-1-git-send-email-opurdila@ixiacom.com>
Cc: Octavian Purdila <opurdila@ixiacom.com>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	Linux Kernel Developers <linux-kernel@vger.kernel.org>,
	WANG Cong <amwang@redhat.com>,
	Neil Horman <nhorman@tuxdriver.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	"Eric W. Biederman" <ebiederm@xmission.com>
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch introduces /proc/sys/net/ipv4/ip_local_reserved_ports which
allows users to reserve ports for third-party applications.

The reserved ports will not be used by automatic port assignments
(e.g. when calling connect() or bind() with port number 0). Explicit
port allocation behavior is unchanged.

Changes from the previous version:
- switch the /proc entry format to coma separated list of range ports
- treat -EFAULT just like any other error and acknowledge written values
- use isdigit() in proc_get_ulong

Octavian Purdila (3):
  sysctl: refactor integer handling proc code
  sysctl: add proc_do_large_bitmap
  net: reserve ports for applications using fixed port numbers

 Documentation/networking/ip-sysctl.txt |   14 +
 drivers/infiniband/core/cma.c          |    7 +-
 include/linux/sysctl.h                 |    2 +
 include/net/ip.h                       |    6 +
 kernel/sysctl.c                        |  449 +++++++++++++++++++++-----------
 net/ipv4/af_inet.c                     |    8 +-
 net/ipv4/inet_connection_sock.c        |    6 +
 net/ipv4/inet_hashtables.c             |    2 +
 net/ipv4/sysctl_net_ipv4.c             |   17 ++
 net/ipv4/udp.c                         |    3 +-
 net/sctp/socket.c                      |    2 +
 11 files changed, 361 insertions(+), 155 deletions(-)
