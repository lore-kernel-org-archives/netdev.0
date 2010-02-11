From: Octavian Purdila <opurdila@ixiacom.com>
Subject: [net-next PATCH v3 0/3] net: reserve ports for applications using fixed port numbers
Date: Thu, 11 Feb 2010 04:09:17 +0200
Message-ID: <1265854160-11763-1-git-send-email-opurdila@ixiacom.com>
Cc: Octavian Purdila <opurdila@ixiacom.com>, netdev@vget.kernel.org,
	linux-kernel@vger.kernel.org, WANG Cong <amwang@redhat.com>,
	Neil Horman <nhorman@tuxdriver.com>,
	Eric Dumazet <eric.dumazet@gmail.com>
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


This patch series is based on Amerigo's v2 but it now uses a bitmap
for port reservation.

I've ran a while (1) { bind(0) } test (with ip_local_port_range
1024 65000) to see if there is any performance difference between the
two approaches (ranges vs bitmap). I could not detect any significant
difference, both cases scored in 2.76s +/- 0.01 on my setup.

I've based this patch series on current net-next, but it contains a
significant non networking part. Please let me know if I should handle
this differently.

Octavian Purdila (3):
  sysctl: refactor integer handling proc code
  sysctl: add proc_dobitmap
  net: reserve ports for applications using fixed port numbers

 Documentation/networking/ip-sysctl.txt |   12 +
 drivers/infiniband/core/cma.c          |    7 +-
 include/linux/sysctl.h                 |    2 +
 include/net/ip.h                       |    6 +
 kernel/sysctl.c                        |  374 +++++++++++++++++++-------------
 net/ipv4/inet_connection_sock.c        |    5 +
 net/ipv4/inet_hashtables.c             |    2 +
 net/ipv4/sysctl_net_ipv4.c             |    7 +
 net/ipv4/udp.c                         |    3 +-
 net/sctp/socket.c                      |    2 +
 10 files changed, 264 insertions(+), 156 deletions(-)
