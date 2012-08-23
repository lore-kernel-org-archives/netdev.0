From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: [PATCH net-next V3 0/2] Add rtnl_link_ops support to IPoIB
Date: Thu, 23 Aug 2012 15:15:17 +0300
Message-ID: <1345724119-32110-1-git-send-email-ogerlitz@mellanox.com>
Cc: roland@kernel.org, netdev@vger.kernel.org,
	Or Gerlitz <ogerlitz@mellanox.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog103.obsmtp.com ([207.126.144.115]:37984 "HELO
	eu1sys200aog103.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S932106Ab2HWMPa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Aug 2012 08:15:30 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is about adding rtnl_link_ops to IPoIB, primarly addressing feedback 
from Dave on a similar patch that was part of the eIPoIB submission.

Also added the releated iproute2 patch, for the sake of the review and 
testing, e.g example usages: 

$ ip link add link ib0 name ib0.1 type ipoib 
$ ip link add link ib0 name ib0.8001 type ipoib pkey 0x8001

and the obvious

$ link delete dev ib0.8001
$ link delete dev ib0.1

Changes from V2:
 - removed the notion of user defined index per child, since we can do well w.o it 
 - for that end, make (an internal to ipoib) distrinction between legacy childs created 
   through the old sysfs way to childs created using rtnl link ops

Changes from V1: 
 - applied feedback from Dave Miller to avoid using sysfs
 - added rtnl_link_ops support in ipoib and use them to add/delete childs

Or Gerlitz (1):
  IB/ipoib: Add rtnl_link_ops support

 Documentation/infiniband/ipoib.txt           |    3 +
 drivers/infiniband/ulp/ipoib/Makefile        |    3 +-
 drivers/infiniband/ulp/ipoib/ipoib.h         |   13 +++
 drivers/infiniband/ulp/ipoib/ipoib_main.c    |   25 ++++-
 drivers/infiniband/ulp/ipoib/ipoib_netlink.c |  122 ++++++++++++++++++++++++++
 drivers/infiniband/ulp/ipoib/ipoib_vlan.c    |  102 ++++++++++++----------
 6 files changed, 217 insertions(+), 51 deletions(-)
 create mode 100644 drivers/infiniband/ulp/ipoib/ipoib_netlink.c
