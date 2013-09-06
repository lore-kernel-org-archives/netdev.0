From: Ding Tianhong <dingtianhong@huawei.com>
Subject: [PATCH net-next v4 0/6] bonding: Patchset for rcu use in bonding
Date: Fri, 6 Sep 2013 15:27:48 +0800
Message-ID: <522983F4.6080900@huawei.com>
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
Received: from szxga01-in.huawei.com ([119.145.14.64]:24355 "EHLO
	szxga01-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750721Ab3IFH2O (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Sep 2013 03:28:14 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi:

The Patch Set convert the xmit of 3ad and alb mode to use rcu lock.
restructure and add more rcu list function.
add rtnl lock to protect bonding_store_xmit_hash().
remove read lock in bond_3ad_lacpdu_recv().

I test the patch well and no problems found till now.

v1: add 1 patch named remove the no effect lock for bond_3ad_lacpdu_recv().
    get the advice from Nikolay Aleksandrov, and modify some mistake in the code.

v2: accept the Nikolay Aleksandrov's advise, modify the patch 05/06.
    the new bond_for_each_slave_from will not use bond->slave_cnt and int cnt any more,
    it test well.
    move the rcu_dereference call of curr_active_slave after the lock avoid 
    a race condition with the slave removal. 

v3: according to the advise of Veaceslav Falico and David S. Miller, modify the patch 01/06 and patch 05/06.
    add rcu protect for read bond->slave_list.
    simplify the bond_for_each_slave_from() and  bond_for_each_slave_from_rcu()

v4: thanks for Veaceslav Falico's patient guidance, fix the problem of patch 01/06 and
patch 05/06.
    restructure the bond_first_slave_rcu().
    restructure the bond_for_each_slave() and bond_for_each_slave_rcu().

Ding Tianhong (4):
Wang Yufen (1):
Yang Yingliang (1):
  root (6):
  bonding: simplify and use RCU protection for 3ad xmit path
  bonding: remove the no effect lock for bond_3ad_lacpdu_recv()
  bonding: replace read_lock to rcu_read_lock for
  bond_3ad_get_active_agg_info()
  bonding: add rtnl lock for bonding_store_xmit_hash
  bonding: restructure and add rcu for bond_for_each_slave_next()
  bonding: use RCU protection for alb xmit path

 drivers/net/bonding/bond_3ad.c   | 38 ++++++++++++---------------
 drivers/net/bonding/bond_alb.c   | 23 +++++++----------
 drivers/net/bonding/bond_main.c  |  6 ++---
 drivers/net/bonding/bond_sysfs.c |  4 +++
 drivers/net/bonding/bonding.h    | 56 +++++++++++++++++++++++++++++++++++-----
 5 files changed, 82 insertions(+), 45 deletions(-)

-- 
1.8.2.1
