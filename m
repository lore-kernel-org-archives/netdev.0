From: Ding Tianhong <dingtianhong@huawei.com>
Subject: [PATCH net-next v3 0/2] bonding: fix primary problem for bonding
Date: Sat, 18 Jan 2014 16:28:47 +0800
Message-ID: <52DA3B3F.5090004@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
To: Jay Vosburgh <fubar@us.ibm.com>,
	Veaceslav Falico <vfalico@redhat.com>,
	Netdev <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga02-in.huawei.com ([119.145.14.65]:49549 "EHLO
	szxga02-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752144AbaARI3M (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 18 Jan 2014 03:29:12 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If the slave's name changed, and the bond params primary is exist,
the bond should deal with the situation in two ways:

1) If the slave was the primary slave yet, clean the primary slave
   and reselect active slave.
2) If the slave's new name is as same as bond primary, set the slave
   as primary slave and reselect active slave.

If the new primary is not matching any slave in the bond, the bond should
record it to params, clean the primary slave and select a new active slave.

Update bonding.txt for primary description.

v2.1->v1: Because there are too many indentions and useless verification, so rewrite
	  the logic for updating the primary slave.
	  Modify some comments for to clean the typos.

v3->v2.1: Veaceslav disagree the first patch and modify the logic for it
	  (bonding: update the primary slave when changing slave's name)
	  and resend it himself (bonding: handle slave's name change with primary_slave logic),
	  so remove the first patch and send the last two patches.

Ding Tianhong (2):
  bonding: clean the primary slave if there is no slave matching new
    primary
  bonding: update bonding.txt for primary description.

 Documentation/networking/bonding.txt | 3 ++-
 drivers/net/bonding/bond_options.c   | 6 ++++++
 2 files changed, 8 insertions(+), 1 deletion(-)

-- 
1.8.0
