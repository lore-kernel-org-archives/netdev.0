From: Ding Tianhong <dingtianhong@huawei.com>
Subject: [PATCH net-next v2 0/3] bonding: fix primary problem for bonding
Date: Tue, 14 Jan 2014 16:41:35 +0800
Message-ID: <52D4F83F.1060802@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
To: Jay Vosburgh <fubar@us.ibm.com>,
	Veaceslav Falico <vfalico@redhat.com>,
	Netdev <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga01-in.huawei.com ([119.145.14.64]:37759 "EHLO
	szxga01-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751071AbaANIm0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Jan 2014 03:42:26 -0500
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

Ding Tianhong (3):
  bonding: update the primary slave when changing slave's name
  bonding: clean the primary slave if there is no slave matching new
    primary
  bonding: update bonding.txt for primary description.

 Documentation/networking/bonding.txt |  3 ++-
 drivers/net/bonding/bond_main.c      | 24 ++++++++++++++++++++++--
 drivers/net/bonding/bond_options.c   |  6 ++++++
 3 files changed, 30 insertions(+), 3 deletions(-)

-- 
1.8.0
