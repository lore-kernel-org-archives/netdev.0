From: =?utf-8?q?R=C3=A9mi=20Denis-Courmont?=
	<remi.denis-courmont-xNZwKgViW5gAvxtiuMwx3w@public.gmane.org>
Subject: [PATCH 2/4] f_phonet: no need to check for carrier - scheduler does it internally
Date: Mon,  6 Apr 2009 18:02:55 +0300
Message-ID: <1239030177-28783-2-git-send-email-remi.denis-courmont@nokia.com>
References: <200904061758.58057.remi.denis-courmont@nokia.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <200904061758.58057.remi.denis-courmont-xNZwKgViW5gAvxtiuMwx3w@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

=46rom: R=C3=A9mi Denis-Courmont <remi.denis-courmont-xNZwKgViW5gAvxtiuMwx3w@public.gmane.org>

Signed-off-by: R=C3=A9mi Denis-Courmont <remi.denis-courmont-xNZwKgViW5gAvxtiuMwx3w@public.gmane.org>
---
 drivers/usb/gadget/f_phonet.c |    8 ++------
 1 files changed, 2 insertions(+), 6 deletions(-)

diff --git a/drivers/usb/gadget/f_phonet.c b/drivers/usb/gadget/f_phone=
t.c
index 54451ee..dff7bae 100644
--- a/drivers/usb/gadget/f_phonet.c
+++ b/drivers/usb/gadget/f_phonet.c
@@ -188,8 +188,7 @@ static struct usb_descriptor_header *hs_pn_function=
[] =3D {
=20
 static int pn_net_open(struct net_device *dev)
 {
-	if (netif_carrier_ok(dev))
-		netif_wake_queue(dev);
+	netif_wake_queue(dev);
 	return 0;
 }
=20
@@ -219,8 +218,7 @@ static void pn_tx_complete(struct usb_ep *ep, struc=
t usb_request *req)
 	}
=20
 	dev_kfree_skb_any(skb);
-	if (netif_carrier_ok(dev))
-		netif_wake_queue(dev);
+	netif_wake_queue(dev);
 }
=20
 static int pn_net_xmit(struct sk_buff *skb, struct net_device *dev)
@@ -427,8 +425,6 @@ static int pn_set_alt(struct usb_function *f, unsig=
ned intf, unsigned alt)
 			fp->in_ep->driver_data =3D fp;
=20
 			netif_carrier_on(dev);
-			if (netif_running(dev))
-				netif_wake_queue(dev);
 			for (i =3D 0; i < phonet_rxq_size; i++)
 				pn_rx_submit(fp, fp->out_reqv[i], GFP_ATOMIC);
 		}
--=20
1.5.6.5

--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
