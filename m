From: Ding Tianhong <dingtianhong@huawei.com>
Subject: [PATCH net-next 0/3] bonding: Fix some issues for fail_over_mac
Date: Wed, 22 Jan 2014 17:21:56 +0800
Message-ID: <52DF8DB4.20104@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
To: Jay Vosburgh <fubar@us.ibm.com>,
	Veaceslav Falico <vfalico@redhat.com>,
	"David S. Miller" <davem@davemloft.net>,
	Netdev <netdev@vger.kernel.org>,
	Andy Gospodarek <andy@greyhouse.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga01-in.huawei.com ([119.145.14.64]:17637 "EHLO
	szxga01-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754737AbaAVJXC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Jan 2014 04:23:02 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The parameter fail_over_mac only affect active-backup mode, if it was
set to active or follow and works with other modes, just like RR or XOR
mode, the bonding could not set all slaves to the master's address, it
will cause the slave could not work well with master.

So set the fail_over_mac to none if the mode is not active-backup and
slight optimization for bond_set_mac_address().

v1->v2: According Jay's suggestion, that we should permit setting an option
	at any time, but only have it take effect in active-backup mode, so
	I add mode checking together with fail_over_mac during enslavement and
	rebuild the patches.

Regards
Ding

Ding Tianhong (3):
  bonding: Set the correct value to fail_over_mac at enslavement
  bonding: only affect active-backup mode when fail_over_mac is not
    none
  bonding: cleanup some redundant code and wrong variables

 drivers/net/bonding/bond_main.c | 26 ++++++++++++++------------
 1 file changed, 14 insertions(+), 12 deletions(-)

-- 
1.8.0
