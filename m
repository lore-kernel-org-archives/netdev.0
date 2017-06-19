From: Julien Gomes <julien@arista.com>
Subject: [PATCH net-next v2 0/4] ipmr/ip6mr: add Netlink notifications on cache reports
Date: Mon, 19 Jun 2017 13:44:13 -0700
Message-ID: <20170619204417.13230-1-julien@arista.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        sharpd@cumulusnetworks.com, nicolas.dichtel@6wind.com,
        Julien Gomes <julien@arista.com>
To: davem@davemloft.net, nikolay@cumulusnetworks.com
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

Changes in v2:
- Changed attributes naming from {IPMRA,IP6MRA}_CACHEREPORTA_* to
  {IPMRA,IP6MRA}_CREPORT_*
- Improved packet data copy to handle non-linear packets in
  ipmr/ip6mr cache report Netlink notification creation
- Added two rtnetlink groups with restricted-binding
- Changed cache report notified groups from RTNL_{IPV4,IPV6}_MROUTE to
  the new restricted groups in ipmr/ip6mr

Julien Gomes (4):
  rtnetlink: add NEWCACHEREPORT message type
  rtnetlink: add restricted rtnl groups for ipv4 and ipv6 mroute
  ipmr: add netlink notifications on igmpmsg cache reports
  ip6mr: add netlink notifications on mrt6msg cache reports

 include/uapi/linux/mroute.h    | 12 ++++++++
 include/uapi/linux/mroute6.h   | 12 ++++++++
 include/uapi/linux/rtnetlink.h |  7 +++++
 net/core/rtnetlink.c           | 13 ++++++++
 net/ipv4/ipmr.c                | 67 ++++++++++++++++++++++++++++++++++++++++--
 net/ipv6/ip6mr.c               | 67 ++++++++++++++++++++++++++++++++++++++++--
 security/selinux/nlmsgtab.c    |  3 +-
 7 files changed, 176 insertions(+), 5 deletions(-)

-- 
2.13.1
