From: Ding Tianhong <dingtianhong@huawei.com>
Subject: [PATCH net-next 0/6] bonding: Patchset for rcu use in bonding
Date: Fri, 30 Aug 2013 18:04:38 +0800
Message-ID: <52206E36.9060901@huawei.com>
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
Received: from szxga01-in.huawei.com ([119.145.14.64]:32396 "EHLO
	szxga01-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754288Ab3H3KFH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 Aug 2013 06:05:07 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi:

The Patch Set convert the xmit of 3ad and alb mode to use rcu lock.
replace and add more rcu list function.
add rtnl lock to protect bonding_store_xmit_hash().
remove read lock in bond_3ad_lacpdu_recv().

I test the patch well and no problems found till now.

v1: add 1 patch named remove the no effect lock for bond_3ad_lacpdu_recv().
    get the advice from Nikolay Aleksandrov, and modify some mistake in the code.	

Ding Tianhong (4):
Wang Yufen (1):
Yang Yingliang (1):
  bonding: simplify and use RCU protection for 3ad xmit path
  bonding: remove the no effect lock for bond_3ad_lacpdu_recv()
  bonding: replace read_lock to rcu_read_lock for
  bond_3ad_get_active_agg_info()
  bonding: add rtnl lock for bonding_store_xmit_hash
  bonding: restructure and simplify bond_for_each_slave_next()
  bonding: use RCU protection for alb xmit path

 drivers/net/bonding/bond_3ad.c   | 38 +++++++++++++++--------------------
 drivers/net/bonding/bond_alb.c   | 23 ++++++++++-----------
 drivers/net/bonding/bond_main.c  |  6 ++----
 drivers/net/bonding/bond_sysfs.c |  4 ++++
 drivers/net/bonding/bonding.h    | 43 +++++++++++++++++++++++++++++++++++-----
 5 files changed, 70 insertions(+), 44 deletions(-)

-- 
1.8.2.1
