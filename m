From: Ding Tianhong <dingtianhong@huawei.com>
Subject: [PATCH net 0/2] bonding: ensure that the TSO being set on bond master
Date: Wed, 8 Jan 2014 15:28:21 +0800
Message-ID: <52CCFE15.2020605@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
To: Jay Vosburgh <fubar@us.ibm.com>,
	Veaceslav Falico <vfalico@redhat.com>,
	Eric Dumazet <edumazet@google.com>,
	"David S. Miller" <davem@davemloft.net>,
	Netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga03-in.huawei.com ([119.145.14.66]:47585 "EHLO
	szxga03-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750790AbaAHH2o (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Jan 2014 02:28:44 -0500
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

Ding Tianhong (2):
  bonding: ensure that the TSO being set on bond master
  net: remove the unused function netdev_add_tso_features()

 drivers/net/bonding/bond_main.c | 16 +++++++++++++++-
 include/linux/netdevice.h       | 10 ----------
 2 files changed, 15 insertions(+), 11 deletions(-)

-- 
1.8.0
