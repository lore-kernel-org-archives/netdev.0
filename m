From: Ding Tianhong <dingtianhong@huawei.com>
Subject: [PATCH net 0/3] bonding: add port protection for bond_3ad_xxx_change()
Date: Fri, 13 Dec 2013 17:29:15 +0800
Message-ID: <52AAD36B.40103@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
To: Jay Vosburgh <fubar@us.ibm.com>,
	Andy Gospodarek <andy@greyhouse.net>,
	"David S. Miller" <davem@davemloft.net>,
	Veaceslav Falico <vfalico@redhat.com>,
	Netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga03-in.huawei.com ([119.145.14.66]:58366 "EHLO
	szxga03-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751618Ab3LMJag (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Dec 2013 04:30:36 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jay Vosburgh said that the bond_3ad_adapter_speed_changed and 
bond_3ad_adapter_duplex_changed is called with RTNL only, and
the functions will modify the port's information with no further
locking, they will not mutex against bond state machine and
incoming LACPDU which do not hold RTNL, So I add port lock to
protect the port information.

But they are not critical bugs, they exist since day one, and till
now they have never been hit and reported, because change for speed
and duplex is very rare, and will not occur critical problem.

The comments in the function is very old, cleanup the comments together.

Ding Tianhong (3):
  bonding: protect port for bond_3ad_adapter_speed_changed()
  bonding: protect port for bond_3ad_adapter_duplex_changed()
  bonding: protect port for bond_3ad_handle_link_change()

 drivers/net/bonding/bond_3ad.c | 45 +++++++++++++++++++++++++++++++-----------
 1 file changed, 33 insertions(+), 12 deletions(-)

-- 
1.8.0
