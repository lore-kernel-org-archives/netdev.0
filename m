From: Ding Tianhong <dingtianhong@huawei.com>
Subject: [PATCH net-next v2 0/6] slight optimization of addr compare for some
 modules
Date: Mon, 16 Dec 2013 16:24:19 +0800
Message-ID: <52AEB8B3.5010405@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
To: "David S. Miller" <davem@davemloft.net>,
	Netdev <netdev@vger.kernel.org>, Joe Perches <joe@perches.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga01-in.huawei.com ([119.145.14.64]:58445 "EHLO
	szxga01-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751983Ab3LPIYf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Dec 2013 03:24:35 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Joe Perches add ether_addr_equal_unaligned to test if
possibly unaligned to u16 Ethernet addresses are equal.

If CONFIG_HAVE_EFFICIENT_UNALIGNED_ACCESS is set, this uses
the slightly faster generic routine ether_addr_equal,
otherwise this uses memcmp.

So I replace memcmp with ether_addr_equal_unaligned in some place
for slight optimization.

v1->v2: modify the patch 02/06's indentation.

Regards.
Ding

Ding Tianhong (6):
  bonding: use ether_addr_equal_unaligned for bond addr compare
  mac80211: slight optimization of addr compare
  fddi: slight optimization of addr compare
  isdn: slight optimization of addr compare
  pppoe: slight optimization of addr compare
  plip: slight optimization of addr compare

 drivers/isdn/i4l/isdn_net.c    |  4 +--
 drivers/net/bonding/bond_3ad.c | 62 ++++++++++++++++++++++--------------------
 drivers/net/plip/plip.c        |  2 +-
 drivers/net/ppp/pppoe.c        |  5 ++--
 net/802/fddi.c                 |  5 ++--
 net/mac80211/iface.c           |  8 +++---
 6 files changed, 46 insertions(+), 40 deletions(-)

-- 
1.8.0
