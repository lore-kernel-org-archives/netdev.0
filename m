From: Ding Tianhong <dingtianhong@huawei.com>
Subject: [PATCH net v2 0/2] Fix RTNL: assertion failed at net/core/rtnetlink.c
Date: Wed, 19 Feb 2014 17:05:09 +0800
Message-ID: <1392800711-19264-1-git-send-email-dingtianhong@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <cwang@twopensource.com>, <jiri@resnulli.us>,
	<thomas@glanzmann.de>, <eric.dumazet@gmail.com>,
	<sfeldma@cumulusnetworks.com>, <davem@davemloft.net>,
	<netdev@vger.kernel.org>
To: <fubar@us.ibm.com>, <vfalico@redhat.com>, <andy@greyhouse.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga03-in.huawei.com ([119.145.14.66]:40598 "EHLO
	szxga03-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751836AbaBSJHz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Feb 2014 04:07:55 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The commit 1d3ee88ae0d
(bonding: add netlink attributes to slave link dev)
make the bond_set_active_slave() and bond_set_backup_slave()
use rtmsg_ifinfo to send slave's states and this functions
should be called in RTNL.

But the 902.3ad and ARP monitor did not hold the RTNL when calling
thses two functions, so fix them.

v1->v2: Add new micro to indicate that the notification should be send
	later, not never.
	And add a new patch to fix the same problem for ARP mode.

Ding Tianhong (2):
  bonding: Fix RTNL: assertion failed at net/core/rtnetlink.c for
    802.3ad mode
  bonding: Fix RTNL: assertion failed at net/core/rtnetlink.c for ab
    arp monitor

 drivers/net/bonding/bond_3ad.c  |  16 +++++-
 drivers/net/bonding/bond_main.c | 117 ++++++++++++++++++++++------------------
 drivers/net/bonding/bonding.h   |  47 ++++++++++++++--
 3 files changed, 121 insertions(+), 59 deletions(-)

-- 
1.8.0
