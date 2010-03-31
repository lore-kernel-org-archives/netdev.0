From: Daniel Borca <dborca@yahoo.com>
Subject: Re: [PATCHv3] drivers/net/usb: Add new driver ipheth
Date: Wed, 31 Mar 2010 15:10:52 -0700 (PDT)
Message-ID: <917081.88187.qm@web110406.mail.gq1.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: =?iso-8859-1?Q?L=2E_Alberto_Gim=E9nez?= <agimenez@sysvalve.es>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-usb@vger.kernel.org" <linux-usb@vger.kernel.org>,
	"linville@tuxdriver.com" <linville@tuxdriver.com>,
	"j.dumon@option.com" <j.dumon@option.com>,
	"steve.glendinning@smsc.com" <steve.glendinning@smsc.com>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"gregkh@suse.de" <gregkh@suse.de>,
	"dgiagio@gmail.com" <dgiagio@gmail.com>
To: Oliver Neukum <oliver@neukum.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello,

Thanks for the comments.  I've already fixed a few things.  We'll fix t=
he remaining ones (below) ASAP. =20

Regards,
Daniel Borca

On 31.03.2010, at 23:33, Oliver Neukum <oliver@neukum.org> wrote:

Am Mittwoch, 31. M=E4rz 2010 21:42:07 schrieb L. Alberto Gim=E9nez:

Hi,

a few comments below.

   Regards
       Oliver

+
+static int ipheth_open(struct net_device *net)
+{
+    struct ipheth_device *dev =3D netdev_priv(net);
+    struct usb_device *udev =3D dev->udev;
+    int retval =3D 0;
+
+    usb_set_interface(udev, IPHETH_INTFNUM, IPHETH_ALT_INTFNUM);
+    usb_clear_halt(udev, usb_rcvbulkpipe(udev, dev->bulk_in));
+    usb_clear_halt(udev, usb_sndbulkpipe(udev, dev->bulk_out));

Is this really needed? If so, please add a comment.

+
+    retval =3D ipheth_carrier_set(dev);
+    if (retval)
+        goto error;
+
+    retval =3D ipheth_rx_submit(dev, GFP_KERNEL);
+    if (retval)
+        goto error;
+
+    schedule_delayed_work(&dev->carrier_work, IPHETH_CARRIER_CHECK_TIM=
EOUT);

Does it make sense to start rx while you have no carrier?

+static int ipheth_tx(struct sk_buff *skb, struct net_device *net)
+{
+    struct ipheth_device *dev =3D netdev_priv(net);
+    struct usb_device *udev =3D dev->udev;
+    int retval;
+
+    /* Paranoid */
+    if (skb->len > IPHETH_BUF_SIZE) {
+        err("%s: skb too large: %d bytes", __func__, skb->len);
+        dev->stats.tx_dropped++;
+        dev_kfree_skb_irq(skb);
+        goto exit;
+    }
+
+    memset(dev->tx_buf, 0, IPHETH_BUF_SIZE);
+    memcpy(dev->tx_buf, skb->data, skb->len);

a bit wasteful

+static void ipheth_disconnect(struct usb_interface *intf)
+{
+    struct ipheth_device *dev;
+
+    dev =3D usb_get_intfdata(intf);
+    if (dev !=3D NULL) {

is this check needed?

+static struct usb_driver ipheth_driver =3D {
+    .name =3D        "ipheth",
+    .probe =3D    ipheth_probe,
+    .disconnect =3D    ipheth_disconnect,
+    .id_table =3D    ipheth_table,
+    .supports_autosuspend =3D 0,

redundant



     =20
