From: Viral Mehta <Viral.Mehta@lntinfotech.com>
Subject: RE: [PATCH v3] can: Add driver for esd CAN-USB/2 device
Date: Mon, 31 May 2010 12:05:50 +0530
Message-ID: <2B8BB46015B5984383F155EB036F018E3E760E39@VSHINMSMBX01.vshodc.lntinfotech.com>
References: <201005261114.03214.matthias.fuchs@esd.eu>
 <70376CA23424B34D86F1C7DE6B9973430254343AD9@VSHINMSMBX01.vshodc.lntinfotech.com>
 <201005281725.32049.matthias.fuchs@esd.eu>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"Socketcan-core@lists.berlios.de" <Socketcan-core@lists.berlios.de>,
	"linux-usb@vger.kernel.org" <linux-usb@vger.kernel.org>
To: Matthias Fuchs <matthias.fuchs@esd.eu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail192.messagelabs.com ([216.82.241.243]:11865 "EHLO
	mail192.messagelabs.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753400Ab0EaGf7 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 31 May 2010 02:35:59 -0400
In-Reply-To: <201005281725.32049.matthias.fuchs@esd.eu>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

> -----Original Message-----
> From: Matthias Fuchs [mailto:matthias.fuchs@esd.eu]
> Sent: Friday, May 28, 2010 8:56 PM
> To: Viral Mehta
> Cc: netdev@vger.kernel.org; Socketcan-core@lists.berlios.de; linux-
> usb@vger.kernel.org
> Subject: Re: [PATCH v3] can: Add driver for esd CAN-USB/2 device
>
> Hi Viral,
>
> thanks for review. Please see some comments below.
>
> On Wednesday 26 May 2010 13:31, Viral Mehta wrote:
> > Hi,
> > >________________________________________
> > >From: linux-usb-owner@vger.kernel.org [linux-usb-
> owner@vger.kernel.org] On Behalf Of Matthias Fuchs
> [matthias.fuchs@esd.eu]
> > >Sent: Wednesday, May 26, 2010 2:44 PM
> > >To: netdev@vger.kernel.org
> > >Cc: Socketcan-core@lists.berlios.de; linux-usb@vger.kernel.org
> > >Subject: [PATCH v3] can: Add driver for esd CAN-USB/2 device
> > >+
> > >+       BUG_ON(!context);
> >
> > It is preferred to used WARN_ON and avoid using BUG_ON and thus dont
> kill the whole system....
> Really? Even when next line will reference a NULL pointer in this case?
> Ok. Will be changed.

How about,
if(!context)
        return;

Look at the other drivers for example.
I, personally, dont care since I will not be using your driver but I am sure that other people, too, wont like BUG_ON....

>
> > [...]
> > >+
> > >+       priv = context->priv;
> > >+       netdev = priv->netdev;
> > >+       dev = priv->usb2;
> > >+       err = usb_submit_urb(urb, GFP_ATOMIC);
> > >+       if (err) {
> > >+               can_free_echo_skb(netdev, context->echo_index);
> > >+
> > >+               atomic_dec(&priv->active_tx_jobs);
> > >+               usb_unanchor_urb(urb);
> > >+
> > >+               stats->tx_dropped++;
> > >+
> > >+               if (err == -ENODEV)
> > >+                       netif_device_detach(netdev);
> > >+               else
> > >+                       dev_warn(netdev->dev.parent, "failed tx_urb
> %d\n", err);
> > >+
> > >+               goto releasebuf;
> >
> > You probably want to set "ret" here or do you really want to return
> NETDEV_TX_OK
> As far as I can see netword device drivers xmit_start() return
> NETDEV_TX_OK or _BUSY.
> There are no real alternatives.
Yup. this is okie....

>But please correct me when I am wrong.
>
> Your other comments will be fixed by version 4 of my patch.
>
> Matthias
>
> ______________________________________________________________________

This Email may contain confidential or privileged information for the intended recipient (s) If you are not the intended recipient, please do not use or disseminate the information, notify the sender and delete it from your system.

______________________________________________________________________
