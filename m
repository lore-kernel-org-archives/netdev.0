From: Ding Tianhong <dingtianhong@huawei.com>
Subject: [PATCH RESEND net-next v3 0/2] bonding: Fix some issues for fail_over_mac
Date: Sat, 25 Jan 2014 12:58:35 +0800
Message-ID: <52E3447B.6050206@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
To: Jay Vosburgh <fubar@us.ibm.com>,
	Veaceslav Falico <vfalico@redhat.com>,
	"David S. Miller" <davem@davemloft.net>,
	Netdev <netdev@vger.kernel.org>,
	Andy Gospodarek <andy@greyhouse.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga03-in.huawei.com ([119.145.14.66]:49732 "EHLO
	szxga03-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750963AbaAYFCO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 25 Jan 2014 00:02:14 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The parameter fail_over_mac only affect active-backup mode, if it was
set to active or follow and works with other modes, just like RR or XOR
mode, the bonding could not set all slaves to the master's address, it
will cause the slave could not work well with master.

v1->v2: According Jay's suggestion, that we should permit setting an option
	at any time, but only have it take effect in active-backup mode, so
	I add mode checking together with fail_over_mac during enslavement and
	rebuild the patches.

v2->v3: The correct way to fix the problem is that we should not add restrictions when
    	setting options, just need to modify the bond enslave and removal processing
    	to check the mode in addition to fail_over_mac when setting a slave's MAC during
    	enslavement. The change active slave processing already only calls the fail_over_mac
    	function when in active-backup mode.

	Remove the cleanup patch because the net-next is frozen now.

Regards
Ding

Ding Tianhong (2):
  bonding: bonding: fail_over_mac should only affect AB mode at
    enslave and removal processing
  bonding: fail_over_mac should only affect AB mode in
    bond_set_mac_address()

 drivers/net/bonding/bond_main.c | 25 +++++++++++++++++--------
 1 file changed, 17 insertions(+), 8 deletions(-)

-- 
1.8.0
