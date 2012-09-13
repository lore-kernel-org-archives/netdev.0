From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: [PATCH net-next V4 0/2] Add rtnl_link_ops support to IPoIB
Date: Thu, 13 Sep 2012 18:56:35 +0300
Message-ID: <1347551797-2495-1-git-send-email-ogerlitz@mellanox.com>
Cc: netdev@vger.kernel.org, Or Gerlitz <ogerlitz@mellanox.com>
To: davem@davemloft.net, roland@kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog103.obsmtp.com ([207.126.144.115]:45954 "HELO
	eu1sys200aog103.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1758456Ab2IMP4q (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Sep 2012 11:56:46 -0400
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

Dave, as I reported over the V3 thread / http://marc.info/?l=linux-netdev&m=134744666921839&w=2
with latest net-next I see a lockdep warning when the module is unloaded which I'm
not sure if real or false, decided to keep with the submission, but I'm open to comments.

Roland, this patch is hanging out for pretty long while (few months) without 
any comment from you, if it makes things easier, I would like to merge it through
net-next, makes sense?

Or.
 
Changes from V3:
 - addressed feedback from Patrick McHardy to move the IFLA_IPOIB_yyy ipoib 
   rtnl defintions into include/linux/if_link.h 
 - changed IFLA_IPOIB_CHILD_PKEY to be named IFLA_IPOIB_PKEY which will cope
   with more IFLA_IPOIB_yyy entries to be added once the basic support is in

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
 drivers/infiniband/ulp/ipoib/ipoib_main.c    |   25 +++++-
 drivers/infiniband/ulp/ipoib/ipoib_netlink.c |  114 ++++++++++++++++++++++++++
 drivers/infiniband/ulp/ipoib/ipoib_vlan.c    |  102 +++++++++++++----------
 include/linux/if_link.h                      |   11 +++
 7 files changed, 220 insertions(+), 51 deletions(-)
 create mode 100644 drivers/infiniband/ulp/ipoib/ipoib_netlink.c
