From: Sebastian Andrzej Siewior <bigeasy@linutronix.de>
Subject: [RFC] net/fs_enet: send a reset request to the PHY on init
Date: Wed, 2 Sep 2009 13:04:10 +0200
Message-ID: <20090902110410.GC15401@www.tglx.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: linuxppc-dev@ozlabs.org, netdev@vger.kernel.org
To: Pantelis Antoniou <pantelis.antoniou@gmail.com>,
	Vitaly Bordug <vbordug@ru.mvista.com>
Return-path: <linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@lists.ozlabs.org>
Content-Disposition: inline
List-Unsubscribe: <https://lists.ozlabs.org/options/linuxppc-dev>,
	<mailto:linuxppc-dev-request@lists.ozlabs.org?subject=unsubscribe>
List-Archive: <http://lists.ozlabs.org/pipermail/linuxppc-dev>
List-Post: <mailto:linuxppc-dev@lists.ozlabs.org>
List-Help: <mailto:linuxppc-dev-request@lists.ozlabs.org?subject=help>
List-Subscribe: <https://lists.ozlabs.org/listinfo/linuxppc-dev>,
	<mailto:linuxppc-dev-request@lists.ozlabs.org?subject=subscribe>
Sender: linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@lists.ozlabs.org
Errors-To: linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@lists.ozlabs.org
List-Id: netdev.vger.kernel.org

Usually u-boot sends a phy request in its network init routine. An uboot
without network support doesn't do it and I endup without working
network. I still can switch between 10/100Mbit (according to the LED on
the hub and phy registers) but I can't send or receive any data.

At this point I'm not sure if the PowerON Reset takes the PHY a few
nsecs too early out of reset or if this reset is required and everyone
relies on U-boot performing this reset.

Signed-off-by: Sebastian Andrzej Siewior <bigeasy@linutronix.de>
---
This is done on a custom mpc512x board. Unfortunately I don't have other
boards to check. The PHY is a AMD Am79C874, phylib uses the generic one.

 drivers/net/fs_enet/fs_enet-main.c |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/drivers/net/fs_enet/fs_enet-main.c b/drivers/net/fs_enet/fs_enet-main.c
index ee15402..a3c962b 100644
--- a/drivers/net/fs_enet/fs_enet-main.c
+++ b/drivers/net/fs_enet/fs_enet-main.c
@@ -823,7 +823,8 @@ static int fs_init_phy(struct net_device *dev)
 	}
 
 	fep->phydev = phydev;
-
+	phy_write(phydev, MII_BMCR, BMCR_RESET);
+	udelay(1);
 	return 0;
 }
 
-- 
1.6.4.GIT
