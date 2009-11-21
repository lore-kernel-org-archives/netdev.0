From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next-2.6 PATCH 09/23] e1000e: Incorrect MII Link beat reporting.
Date: Sat, 21 Nov 2009 01:24:30 -0800
Message-ID: <20091121092429.5715.63723.stgit@localhost.localdomain>
References: <20091121092126.5715.41618.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	Bruce Allan <bruce.w.allan@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta11.emeryville.ca.mail.comcast.net ([76.96.27.211]:55782
	"EHLO QMTA11.emeryville.ca.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752614AbZKUJYk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 21 Nov 2009 04:24:40 -0500
In-Reply-To: <20091121092126.5715.41618.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Bruce Allan <bruce.w.allan@intel.com>

The driver was only updating MII stats when an LSC up was detected and
the interface had not already been reported up to netdev. This meant
MII stats returned in response to an SIOCGMIIREG ioctl would always
show a link up if it had ever been up. This was misleading the networking
daemon guessnet, which uses this ioctl, into making improper network port
selections.
This fix adds a call to e1000_phy_read_status() to actively read the
mii stats before responding to the SIOCGMIIREG ioctl.

Signed-off-by: Bruce Allan <bruce.w.allan@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/e1000e/netdev.c |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/drivers/net/e1000e/netdev.c b/drivers/net/e1000e/netdev.c
index e819f19..ff9f9f1 100644
--- a/drivers/net/e1000e/netdev.c
+++ b/drivers/net/e1000e/netdev.c
@@ -4320,6 +4320,8 @@ static int e1000_mii_ioctl(struct net_device *netdev, struct ifreq *ifr,
 		data->phy_id = adapter->hw.phy.addr;
 		break;
 	case SIOCGMIIREG:
+		e1000_phy_read_status(adapter);
+
 		switch (data->reg_num & 0x1F) {
 		case MII_BMCR:
 			data->val_out = adapter->phy_regs.bmcr;

