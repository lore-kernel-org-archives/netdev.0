From: Pavel Roskin <proski-mXXj517/zsQ@public.gmane.org>
Subject: [PATCH 09/21] orinoco: orinoco_xmit() should only return valid symbolic constants
Date: Fri, 07 Apr 2006 04:10:36 -0400
Message-ID: <20060407081036.16107.96227.stgit@dv.roinet.com>
References: <20060407081019.16107.67672.stgit@dv.roinet.com>
Content-Type: text/plain; charset=utf-8; format=fixed
Content-Transfer-Encoding: quoted-printable
Cc: orinoco-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
Return-path: <orinoco-devel-admin-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
To: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
In-Reply-To: <20060407081019.16107.67672.stgit-fdEtzkpK75rby3iVrkZq2A@public.gmane.org>
Sender: orinoco-devel-admin-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
Errors-To: orinoco-devel-admin-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/orinoco-devel>,
	<mailto:orinoco-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=unsubscribe>
List-Post: <mailto:orinoco-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
List-Help: <mailto:orinoco-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/orinoco-devel>,
	<mailto:orinoco-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=subscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=orinoco-devel>
List-Id: netdev.vger.kernel.org

From: Pavel Roskin <proski-mXXj517/zsQ@public.gmane.org>

Don't ever return -errno from orinoco_xmit() - the network layer doesn't
expect it.

Signed-off-by: Pavel Roskin <proski-mXXj517/zsQ@public.gmane.org>
---

 drivers/net/wireless/orinoco.c |   12 ++++++------
 1 files changed, 6 insertions(+), 6 deletions(-)

diff --git a/drivers/net/wireless/orinoco.c b/drivers/net/wireless/orinoc=
o.c
index ceea494..173e9e4 100644
--- a/drivers/net/wireless/orinoco.c
+++ b/drivers/net/wireless/orinoco.c
@@ -430,19 +430,19 @@ static int orinoco_xmit(struct sk_buff *
 	if (! netif_running(dev)) {
 		printk(KERN_ERR "%s: Tx on stopped device!\n",
 		       dev->name);
-		return 1;
+		return NETDEV_TX_BUSY;
 	}
 =09
 	if (netif_queue_stopped(dev)) {
 		printk(KERN_DEBUG "%s: Tx while transmitter busy!\n",=20
 		       dev->name);
-		return 1;
+		return NETDEV_TX_BUSY;
 	}
 =09
 	if (orinoco_lock(priv, &flags) !=3D 0) {
 		printk(KERN_ERR "%s: orinoco_xmit() called while hw_unavailable\n",
 		       dev->name);
-		return 1;
+		return NETDEV_TX_BUSY;
 	}
=20
 	if (! netif_carrier_ok(dev) || (priv->iw_mode =3D=3D IW_MODE_MONITOR)) =
{
@@ -452,7 +452,7 @@ static int orinoco_xmit(struct sk_buff *
 		stats->tx_errors++;
 		orinoco_unlock(priv, &flags);
 		dev_kfree_skb(skb);
-		return 0;
+		return NETDEV_TX_OK;
 	}
=20
 	/* Length of the packet body */
@@ -551,11 +551,11 @@ static int orinoco_xmit(struct sk_buff *
=20
 	dev_kfree_skb(skb);
=20
-	return 0;
+	return NETDEV_TX_OK;
  fail:
=20
 	orinoco_unlock(priv, &flags);
-	return err;
+	return NETDEV_TX_BUSY;
 }
=20
 static void __orinoco_ev_alloc(struct net_device *dev, hermes_t *hw)



-------------------------------------------------------
This SF.Net email is sponsored by xPML, a groundbreaking scripting langua=
ge
that extends applications into web and mobile media. Attend the live webc=
ast
and join the prime developer group breaking into this new coding territor=
y!
http://sel.as-us.falkag.net/sel?cmd=3Dlnk&kid=3D110944&bid=3D241720&dat=3D=
121642
