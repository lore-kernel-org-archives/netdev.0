From: Thomas Graf <tgraf@suug.ch>
Subject: [PATCH net-next 0/2] Get rid of attribute parsing in rtnetlink_rcv_msg()
Date: Thu, 21 Mar 2013 18:45:27 +0100
Message-ID: <cover.1363885020.git.tgraf@suug.ch>
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 173-166-109-252-newengland.hfc.comcastbusiness.net ([173.166.109.252]:39000
	"EHLO bombadil.infradead.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751287Ab3CURph (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Mar 2013 13:45:37 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We have been wanting to get rid of rta_buf for a while. It is error
prone as it requires subsystems, especially modules, that register a
rtnetlink mesage type to also modify rtnetlink.c and thus require
the recompilation of the kernel. DECnet is the only user left so after
converting it we can safely remove it

Thomas Graf (2):
  decnet: Parse netlink attributes on our own
  rtnetlink: Remove passing of attributes into rtnl_doit functions

 include/net/dn_fib.h    |  28 ++-----
 include/net/rtnetlink.h |   2 +-
 net/bridge/br_mdb.c     |   4 +-
 net/can/gw.c            |   5 +-
 net/core/fib_rules.c    |   4 +-
 net/core/neighbour.c    |   6 +-
 net/core/rtnetlink.c    |  82 ++----------------
 net/dcb/dcbnl.c         |   2 +-
 net/decnet/dn_dev.c     |   4 +-
 net/decnet/dn_fib.c     | 215 ++++++++++++++++++++++++++----------------------
 net/decnet/dn_route.c   |  29 ++++---
 net/decnet/dn_table.c   |  42 +++++-----
 net/ipv4/devinet.c      |   7 +-
 net/ipv4/fib_frontend.c |   4 +-
 net/ipv4/route.c        |   2 +-
 net/ipv6/addrconf.c     |  10 +--
 net/ipv6/addrlabel.c    |   6 +-
 net/ipv6/route.c        |   6 +-
 net/phonet/pn_netlink.c |   4 +-
 net/sched/act_api.c     |   2 +-
 net/sched/cls_api.c     |   2 +-
 net/sched/sch_api.c     |   6 +-
 22 files changed, 207 insertions(+), 265 deletions(-)

-- 
1.7.11.7
