From: Oliver Neukum <oneukum@suse.de>
Subject: Re: [PATCH] USBNET: fix handling padding packet
Date: Wed, 18 Sep 2013 19:06:24 +0200
Message-ID: <1379523984.2430.3.camel@linux-fkkt.site>
References: <1379409002-7698-1-git-send-email-ming.lei@canonical.com>
	 <878uyu6xjm.fsf@nemi.mork.no>
	 <CACVXFVNzTGbCV2wQ4RwxXK1q7+eD2KkOS_G3NvL4uAzdd21SUg@mail.gmail.com>
	 <87zjra5dpx.fsf@nemi.mork.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Ming Lei <ming.lei@canonical.com>,
	"David S. Miller" <davem@davemloft.net>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	Network Development <netdev@vger.kernel.org>,
	linux-usb <linux-usb@vger.kernel.org>
To: =?ISO-8859-1?Q?Bj=F8rn?= Mork <bjorn@mork.no>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cantor2.suse.de ([195.135.220.15]:53804 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753302Ab3IRRG0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 18 Sep 2013 13:06:26 -0400
In-Reply-To: <87zjra5dpx.fsf@nemi.mork.no>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2013-09-18 at 17:52 +0200, Bj=C3=B8rn Mork wrote:

> No modern device should need the padding.  No old device will be able=
 to
> use the SG feature as implemented. You only enable it on USB3, don't

On XHCI.

> you? If this feature is restricted to USB3 capable devices, then it m=
ost
> certainly can be restricted to ZLP capable devices with absolutely no
> difference in the resulting set of supported devices.

No, USB 3.0 uses no companion controllers, so you can have devices
of any speed connected to it.

> Anyway, if you want to keep the padding for SG then maybe this will w=
ork
> and allow you to drop the extra struct usbnet field and allocation:
>=20
>                         if (skb_tailroom(skb) && !dev->can_dma_sg) {
>                                skb->data[skb->len] =3D 0;
>                                __skb_put(skb, 1);
>                         } else if (dev->can_dma_sg) {
>                               sg_set_buf(&urb->sg[urb->num_sgs++], sk=
b->data, 1);
>                         }
>=20
> I.e. cheat and use the skb->data buffer twice, if that is allowed?  T=
he
> actual value of the padding byte should not matter, I believe?

That makes me immediately suspect a violation of the DMA rules.

	Regards
		Oliver
