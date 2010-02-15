From: Octavian Purdila <opurdila@ixiacom.com>
Subject: [net-next PATCH v4 0/3] net: reserve ports for applications using fixed port
Date: Tue, 16 Feb 2010 00:00:38 +0200
Message-ID: <1266271241-6293-1-git-send-email-opurdila@ixiacom.com>
Cc: Octavian Purdila <opurdila@ixiacom.com>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	Linux Kernel Developers <linux-kernel@vger.kernel.org>,
	Amerigo Wang <amwang@redhat.com>
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


This iteration makes the bitmap dynamically allocated since it is
quite big (8192 bytes) and adding that much in BSS may still,
apparently, cause problems on some architectures.


Octavian Purdila (3):
  sysctl: refactor integer handling proc code
  sysctl: add proc_dobitmap
  net: reserve ports for applications using fixed port numbers

 Documentation/networking/ip-sysctl.txt |   12 +
 drivers/infiniband/core/cma.c          |    7 +-
 include/linux/sysctl.h                 |    2 +
 include/net/ip.h                       |    6 +
 kernel/sysctl.c                        |  374 +++++++++++++++++++-------------
 net/ipv4/af_inet.c                     |    8 +-
 net/ipv4/inet_connection_sock.c        |    6 +
 net/ipv4/inet_hashtables.c             |    2 +
 net/ipv4/sysctl_net_ipv4.c             |   17 ++
 net/ipv4/udp.c                         |    3 +-
 net/sctp/socket.c                      |    2 +
 11 files changed, 282 insertions(+), 157 deletions(-)
