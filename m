From: Ding Tianhong <dingtianhong@huawei.com>
Subject: [PATCH net-next v2 0/2] bonding: ensure that the TSO being set on
 bond master
Date: Tue, 14 Jan 2014 17:00:07 +0800
Message-ID: <52D4FC97.8020301@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
To: Jay Vosburgh <fubar@us.ibm.com>,
	Veaceslav Falico <vfalico@redhat.com>,
	Eric Dumazet <edumazet@google.com>,
	"David S. Miller" <davem@davemloft.net>,
	Netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga03-in.huawei.com ([119.145.14.66]:41046 "EHLO
	szxga03-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750731AbaANJBR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Jan 2014 04:01:17 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The commit b0ce3508(bonding: allow TSO being set on bonding master)
has make the TSO being set for bond dev, but in some situation, if
the slave did not have the NETIF_F_SG features, the bond master will
miss the TSO features in netdev_fix_features because the TSO is
depended on SG. So I have to add SG and TSO features on bond master
together.

The function netdev_add_tso_features() was only be used for bonding,
so no need to export it in netdevice.h, remove it and add it to bonding.

v2: If the slave hw did not support SG features, the SG should not
    be forced open on master, otherwise error will occur, so modify it.
    Some slave may support SG but not open it yet, so the bond master
    could try to open it when adding the salve and make sure the TSO
    could be open on master.

Ding Tianhong (2):
  bonding: move the netdev_add_tso_features() to bonding
  bonding: try to enable SG features when adding a new slave

 drivers/net/bonding/bond_main.c | 27 ++++++++++++++++++++++++++-
 include/linux/netdevice.h       | 10 ----------
 2 files changed, 26 insertions(+), 11 deletions(-)

-- 
1.8.0
