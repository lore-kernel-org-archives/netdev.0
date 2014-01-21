From: Ding Tianhong <dingtianhong@huawei.com>
Subject: [PATCH net-next 0/5] bonding: Fix some issues for fail_over_mac
Date: Tue, 21 Jan 2014 17:43:48 +0800
Message-ID: <52DE4154.1090907@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
To: Jay Vosburgh <fubar@us.ibm.com>,
	Veaceslav Falico <vfalico@redhat.com>,
	"David S. Miller" <davem@davemloft.net>,
	Netdev <netdev@vger.kernel.org>,
	Andy Gospodarek <andy@greyhouse.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga03-in.huawei.com ([119.145.14.66]:51978 "EHLO
	szxga03-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751613AbaAUJoK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Jan 2014 04:44:10 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The parameter fail_over_mac only affect active-backup mode, if it was
set to active or follow and works with other modes, just like RR or XOR
mode, the bonding could not set all slaves to the master's address, it
will cause the slave could not work well with master.

So set the fail_over_mac to none if the mode is not active-backup and
slight optimization for bond_set_mac_address().

Ding Tianhong (5):
  bonding: The fail_over_mac should be set only in ACTIVE_BACKUP mode
  bonding: don't set fail_over_mac if the mode is not active backup
  bonding: bonding: set fail_over_mac to none if new mode is not active-backup
  bonding: set fail_over_mac to active only in active-backup mode at
    enslavement
  bonding: remove the redundant judgements for bond_set_mac_address()

 drivers/net/bonding/bond_main.c    | 19 +++++++------------
 drivers/net/bonding/bond_options.c | 12 ++++++++++++
 2 files changed, 19 insertions(+), 12 deletions(-)

-- 
1.8.0
