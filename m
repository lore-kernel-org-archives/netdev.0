From: "Sebastian =?ISO-8859-1?Q?P=F6hn?=" <sebastian.poehn@gmail.com>
Subject: [PATCH] staging: octeon-ethernet: trivial: Avoid OOPS if phydev is
 not set
Date: Sun, 13 Oct 2013 20:59:54 +0200
Message-ID: <1381690794.2848.11.camel@alpha.Speedport_W723_V_Typ_A_1_00_098>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: support@caviumnetworks.com, netdev@vger.kernel.org
To: driverdev-devel@linuxdriverproject.org
Return-path: <driverdev-devel-bounces@linuxdriverproject.org>
List-Unsubscribe: <http://driverdev.linuxdriverproject.org/mailman/options/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=unsubscribe>
List-Archive: <http://driverdev.linuxdriverproject.org/pipermail/driverdev-devel>
List-Post: <mailto:driverdev-devel@linuxdriverproject.org>
List-Help: <mailto:driverdev-devel-request@linuxdriverproject.org?subject=help>
List-Subscribe: <http://driverdev.linuxdriverproject.org/mailman/listinfo/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=subscribe>
Errors-To: driverdev-devel-bounces@linuxdriverproject.org
Sender: driverdev-devel-bounces@linuxdriverproject.org
List-Id: netdev.vger.kernel.org

A zero pointer deref on priv->phydev->link was causing oops on our systems.
Might be related to improper configuration but we should fail gracefully here ;-)

Signed-off-by: Sebastian Poehn <sebastian.poehn@googlemail.com>

---

diff --git a/drivers/staging/octeon/ethernet-mdio.c b/drivers/staging/octeon/ethernet-mdio.c
index 83b1030..bc8c503 100644
--- a/drivers/staging/octeon/ethernet-mdio.c
+++ b/drivers/staging/octeon/ethernet-mdio.c
@@ -121,6 +121,9 @@ static void cvm_oct_adjust_link(struct net_device *dev)
        struct octeon_ethernet *priv = netdev_priv(dev);
        cvmx_helper_link_info_t link_info;
 
+       if(!priv->phydev)
+               return ;
+
        if (priv->last_link != priv->phydev->link) {
                priv->last_link = priv->phydev->link;
                link_info.u64 = 0;
