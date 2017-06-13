From: Julien Gomes <julien@arista.com>
Subject: [PATCH net-next 0/3] ipmr/ip6mr: add Netlink notifications on cache reports
Date: Tue, 13 Jun 2017 10:08:19 -0700
Message-ID: <20170613170822.16310-1-julien@arista.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        nikolay@cumulusnetworks.com, Julien Gomes <julien@arista.com>
To: davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Currently, all ipmr/ip6mr cache reports are sent through the
mroute/mroute6 socket only.
This forces the use of a single socket for mroute programming, cache
reports and, regarding ipmr, IGMP messages without Router Alert option
reception.

The present patches are aiming to send Netlink notifications in addition
to the existing igmpmsg/mrt6msg to give user programs a way to handle
cache reports in parallel with multiple sockets other than the
mroute/mroute6 socket.

Julien Gomes (3):
  rtnetlink: add NEWCACHEREPORT message type
  ipmr: add netlink notifications on igmpmsg cache reports
  ip6mr: add netlink notifications on mrt6msg cache reports

 include/uapi/linux/mroute.h    | 11 ++++++++
 include/uapi/linux/mroute6.h   | 11 ++++++++
 include/uapi/linux/rtnetlink.h |  3 ++
 net/ipv4/ipmr.c                | 63 ++++++++++++++++++++++++++++++++++++++++--
 net/ipv6/ip6mr.c               | 63 ++++++++++++++++++++++++++++++++++++++++--
 security/selinux/nlmsgtab.c    |  3 +-
 6 files changed, 149 insertions(+), 5 deletions(-)

-- 
2.13.1
