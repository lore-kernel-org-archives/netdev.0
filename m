From: Ding Tianhong <dingtianhong@huawei.com>
Subject: [PATCH net-next v2 0/3] bonding: patchset for rcu use in bonding
Date: Tue, 15 Oct 2013 16:28:31 +0800
Message-ID: <525CFCAF.2000605@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
To: Jay Vosburgh <fubar@us.ibm.com>,
	Andy Gospodarek <andy@greyhouse.net>,
	"David S. Miller" <davem@davemloft.net>,
	Nikolay Aleksandrov <nikolay@redhat.com>,
	Veaceslav Falico <vfalico@redhat.com>,
	Netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga02-in.huawei.com ([119.145.14.65]:9746 "EHLO
	szxga02-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752707Ab3JOI3u (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Oct 2013 04:29:50 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi:

The Patch Set convert the xmit of 3ad and alb mode to use rcu lock.
dd rtnl lock and remove read lock for bond sysfs.

v2 because the bond_for_each_slave_rcu without rcu_read_lock() will occurs one warming, so
add new function for alb xmit path to avoid warming.

Ding Tianhong (3):
Wang Yufen (1):
Yang Yingliang (1):
  bonding: use RCU protection for 3ad xmit path
  bonding: use RCU protection for alb xmit path
  bonding: add rtnl lock and remove read lock for bond sysfs

 drivers/net/bonding/bond_3ad.c   | 10 +++----
 drivers/net/bonding/bond_alb.c   | 58 +++++++++++++++++++++++++++++-----------
 drivers/net/bonding/bond_sysfs.c | 30 ++++++++++++---------
 drivers/net/bonding/bonding.h    | 14 ++++++++++
 4 files changed, 78 insertions(+), 34 deletions(-)

-- 
1.8.2.1
