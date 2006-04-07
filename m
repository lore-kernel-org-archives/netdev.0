From: Pavel Roskin <proski-mXXj517/zsQ@public.gmane.org>
Subject: [PATCH 05/21] orinoco: remove tracing code, it's unused
Date: Fri, 07 Apr 2006 04:10:28 -0400
Message-ID: <20060407081028.16107.74341.stgit@dv.roinet.com>
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

Signed-off-by: Pavel Roskin <proski-mXXj517/zsQ@public.gmane.org>
---

 drivers/net/wireless/orinoco.c |   83 ----------------------------------=
------
 drivers/net/wireless/orinoco.h |    3 -
 2 files changed, 0 insertions(+), 86 deletions(-)

diff --git a/drivers/net/wireless/orinoco.c b/drivers/net/wireless/orinoc=
o.c
index 06523e2..9550bf3 100644
--- a/drivers/net/wireless/orinoco.c
+++ b/drivers/net/wireless/orinoco.c
@@ -456,26 +456,21 @@ static int orinoco_xmit(struct sk_buff *
 	struct hermes_tx_descriptor desc;
 	unsigned long flags;
=20
-	TRACE_ENTER(dev->name);
-
 	if (! netif_running(dev)) {
 		printk(KERN_ERR "%s: Tx on stopped device!\n",
 		       dev->name);
-		TRACE_EXIT(dev->name);
 		return 1;
 	}
 =09
 	if (netif_queue_stopped(dev)) {
 		printk(KERN_DEBUG "%s: Tx while transmitter busy!\n",=20
 		       dev->name);
-		TRACE_EXIT(dev->name);
 		return 1;
 	}
 =09
 	if (orinoco_lock(priv, &flags) !=3D 0) {
 		printk(KERN_ERR "%s: orinoco_xmit() called while hw_unavailable\n",
 		       dev->name);
-		TRACE_EXIT(dev->name);
 		return 1;
 	}
=20
@@ -486,7 +481,6 @@ static int orinoco_xmit(struct sk_buff *
 		stats->tx_errors++;
 		orinoco_unlock(priv, &flags);
 		dev_kfree_skb(skb);
-		TRACE_EXIT(dev->name);
 		return 0;
 	}
=20
@@ -585,12 +579,9 @@ static int orinoco_xmit(struct sk_buff *
 	orinoco_unlock(priv, &flags);
=20
 	dev_kfree_skb(skb);
-
-	TRACE_EXIT(dev->name);
=20
 	return 0;
  fail:
-	TRACE_EXIT(dev->name);
=20
 	orinoco_unlock(priv, &flags);
 	return err;
@@ -2274,8 +2265,6 @@ static int orinoco_init(struct net_devic
 	u16 reclen;
 	int len;
=20
-	TRACE_ENTER(dev->name);
-
 	/* No need to lock, the hw_unavailable flag is already set in
 	 * alloc_orinocodev() */
 	priv->nicbuf_size =3D IEEE80211_FRAME_LEN + ETH_HLEN;
@@ -2429,7 +2418,6 @@ static int orinoco_init(struct net_devic
 	printk(KERN_DEBUG "%s: ready\n", dev->name);
=20
  out:
-	TRACE_EXIT(dev->name);
 	return err;
 }
=20
@@ -2796,8 +2784,6 @@ static int orinoco_ioctl_getiwrange(stru
 	struct iw_range *range =3D (struct iw_range *) extra;
 	int numrates;
 	int i, k;
-
-	TRACE_ENTER(dev->name);
=20
 	rrq->length =3D sizeof(struct iw_range);
 	memset(range, 0, sizeof(struct iw_range));
@@ -2888,8 +2874,6 @@ static int orinoco_ioctl_getiwrange(stru
 	IW_EVENT_CAPA_SET(range->event_capa, SIOCGIWSCAN);
 	IW_EVENT_CAPA_SET(range->event_capa, IWEVTXDROP);
=20
-	TRACE_EXIT(dev->name);
-
 	return 0;
 }
=20
@@ -3070,8 +3054,6 @@ static int orinoco_ioctl_getessid(struct
 	int active;
 	int err =3D 0;
 	unsigned long flags;
-
-	TRACE_ENTER(dev->name);
=20
 	if (netif_running(dev)) {
 		err =3D orinoco_hw_get_essid(priv, &active, essidbuf);
@@ -3087,8 +3069,6 @@ static int orinoco_ioctl_getessid(struct
 	erq->flags =3D 1;
 	erq->length =3D strlen(essidbuf) + 1;
=20
-	TRACE_EXIT(dev->name);
-=09
 	return 0;
 }
=20
@@ -4347,69 +4327,6 @@ static struct ethtool_ops orinoco_ethtoo
 	.get_drvinfo =3D orinoco_get_drvinfo,
 	.get_link =3D ethtool_op_get_link,
 };
-
-/********************************************************************/
-/* Debugging                                                        */
-/********************************************************************/
-
-#if 0
-static void show_rx_frame(struct orinoco_rxframe_hdr *frame)
-{
-	printk(KERN_DEBUG "RX descriptor:\n");
-	printk(KERN_DEBUG "  status      =3D 0x%04x\n", frame->desc.status);
-	printk(KERN_DEBUG "  time        =3D 0x%08x\n", frame->desc.time);
-	printk(KERN_DEBUG "  silence     =3D 0x%02x\n", frame->desc.silence);
-	printk(KERN_DEBUG "  signal      =3D 0x%02x\n", frame->desc.signal);
-	printk(KERN_DEBUG "  rate        =3D 0x%02x\n", frame->desc.rate);
-	printk(KERN_DEBUG "  rxflow      =3D 0x%02x\n", frame->desc.rxflow);
-	printk(KERN_DEBUG "  reserved    =3D 0x%08x\n", frame->desc.reserved);
-
-	printk(KERN_DEBUG "IEEE 802.11 header:\n");
-	printk(KERN_DEBUG "  frame_ctl   =3D 0x%04x\n",
-	       frame->p80211.frame_ctl);
-	printk(KERN_DEBUG "  duration_id =3D 0x%04x\n",
-	       frame->p80211.duration_id);
-	printk(KERN_DEBUG "  addr1       =3D %02x:%02x:%02x:%02x:%02x:%02x\n",
-	       frame->p80211.addr1[0], frame->p80211.addr1[1],
-	       frame->p80211.addr1[2], frame->p80211.addr1[3],
-	       frame->p80211.addr1[4], frame->p80211.addr1[5]);
-	printk(KERN_DEBUG "  addr2       =3D %02x:%02x:%02x:%02x:%02x:%02x\n",
-	       frame->p80211.addr2[0], frame->p80211.addr2[1],
-	       frame->p80211.addr2[2], frame->p80211.addr2[3],
-	       frame->p80211.addr2[4], frame->p80211.addr2[5]);
-	printk(KERN_DEBUG "  addr3       =3D %02x:%02x:%02x:%02x:%02x:%02x\n",
-	       frame->p80211.addr3[0], frame->p80211.addr3[1],
-	       frame->p80211.addr3[2], frame->p80211.addr3[3],
-	       frame->p80211.addr3[4], frame->p80211.addr3[5]);
-	printk(KERN_DEBUG "  seq_ctl     =3D 0x%04x\n",
-	       frame->p80211.seq_ctl);
-	printk(KERN_DEBUG "  addr4       =3D %02x:%02x:%02x:%02x:%02x:%02x\n",
-	       frame->p80211.addr4[0], frame->p80211.addr4[1],
-	       frame->p80211.addr4[2], frame->p80211.addr4[3],
-	       frame->p80211.addr4[4], frame->p80211.addr4[5]);
-	printk(KERN_DEBUG "  data_len    =3D 0x%04x\n",
-	       frame->p80211.data_len);
-
-	printk(KERN_DEBUG "IEEE 802.3 header:\n");
-	printk(KERN_DEBUG "  dest        =3D %02x:%02x:%02x:%02x:%02x:%02x\n",
-	       frame->p8023.h_dest[0], frame->p8023.h_dest[1],
-	       frame->p8023.h_dest[2], frame->p8023.h_dest[3],
-	       frame->p8023.h_dest[4], frame->p8023.h_dest[5]);
-	printk(KERN_DEBUG "  src         =3D %02x:%02x:%02x:%02x:%02x:%02x\n",
-	       frame->p8023.h_source[0], frame->p8023.h_source[1],
-	       frame->p8023.h_source[2], frame->p8023.h_source[3],
-	       frame->p8023.h_source[4], frame->p8023.h_source[5]);
-	printk(KERN_DEBUG "  len         =3D 0x%04x\n", frame->p8023.h_proto);
-
-	printk(KERN_DEBUG "IEEE 802.2 LLC/SNAP header:\n");
-	printk(KERN_DEBUG "  DSAP        =3D 0x%02x\n", frame->p8022.dsap);
-	printk(KERN_DEBUG "  SSAP        =3D 0x%02x\n", frame->p8022.ssap);
-	printk(KERN_DEBUG "  ctrl        =3D 0x%02x\n", frame->p8022.ctrl);
-	printk(KERN_DEBUG "  OUI         =3D %02x:%02x:%02x\n",
-	       frame->p8022.oui[0], frame->p8022.oui[1], frame->p8022.oui[2]);
-	printk(KERN_DEBUG "  ethertype  =3D 0x%04x\n", frame->ethertype);
-}
-#endif /* 0 */
=20
 /********************************************************************/
 /* Module initialization                                            */
diff --git a/drivers/net/wireless/orinoco.h b/drivers/net/wireless/orinoc=
o.h
index f5d856d..c6922a7 100644
--- a/drivers/net/wireless/orinoco.h
+++ b/drivers/net/wireless/orinoco.h
@@ -132,9 +132,6 @@ #else
 #define DEBUG(n, args...) do { } while (0)
 #endif	/* ORINOCO_DEBUG */
=20
-#define TRACE_ENTER(devname) DEBUG(2, "%s: -> %s()\n", devname, __FUNCTI=
ON__);
-#define TRACE_EXIT(devname)  DEBUG(2, "%s: <- %s()\n", devname, __FUNCTI=
ON__);
-
 /********************************************************************/
 /* Exported prototypes                                              */
 /********************************************************************/



-------------------------------------------------------
This SF.Net email is sponsored by xPML, a groundbreaking scripting langua=
ge
that extends applications into web and mobile media. Attend the live webc=
ast
and join the prime developer group breaking into this new coding territor=
y!
http://sel.as-us.falkag.net/sel?cmd=3Dlnk&kid=3D110944&bid=3D241720&dat=3D=
121642
