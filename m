From: =?ISO-8859-1?Q?Bj=F8rn_Mork?= <bjorn@mork.no>
Subject: Re: [PATCH] USBNET: fix handling padding packet
Date: Wed, 18 Sep 2013 20:56:15 +0200
Message-ID: <be5ecff3-27e1-4ab7-b3af-9d7c4376140f@email.android.com>
References: <1379409002-7698-1-git-send-email-ming.lei@canonical.com> <878uyu6xjm.fsf@nemi.mork.no> <CACVXFVNzTGbCV2wQ4RwxXK1q7+eD2KkOS_G3NvL4uAzdd21SUg@mail.gmail.com> <87zjra5dpx.fsf@nemi.mork.no> <1379523984.2430.3.camel@linux-fkkt.site>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Ming Lei <ming.lei@canonical.com>,
	"David S. Miller" <davem@davemloft.net>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	Network Development <netdev@vger.kernel.org>,
	linux-usb <linux-usb@vger.kernel.org>
To: Oliver Neukum <oneukum@suse.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from canardo.mork.no ([148.122.252.1]:59986 "EHLO canardo.mork.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751494Ab3IRS4Z (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 18 Sep 2013 14:56:25 -0400
In-Reply-To: <1379523984.2430.3.camel@linux-fkkt.site>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Oliver Neukum <oneukum@suse.de> wrote:
>On Wed, 2013-09-18 at 17:52 +0200, Bj=C3=B8rn Mork wrote:
>
>> No modern device should need the padding.  No old device will be abl=
e
>to
>> use the SG feature as implemented. You only enable it on USB3, don't
>
>On XHCI.
>
>> you? If this feature is restricted to USB3 capable devices, then it
>most
>> certainly can be restricted to ZLP capable devices with absolutely n=
o
>> difference in the resulting set of supported devices.
>
>No, USB 3.0 uses no companion controllers, so you can have devices
>of any speed connected to it.
>

Ah, right. I don't own such modern hardware, but I should have known th=
is anyway.=20

This still doesn't change the fact that the driver is brand new for bra=
nd new devices. I believe we should assume such devices will support ZL=
Ps unless we have documentation stating anything else.

>> Anyway, if you want to keep the padding for SG then maybe this will
>work
>> and allow you to drop the extra struct usbnet field and allocation:
>>=20
>>                         if (skb_tailroom(skb) && !dev->can_dma_sg) {
>>                                skb->data[skb->len] =3D 0;
>>                                __skb_put(skb, 1);
>>                         } else if (dev->can_dma_sg) {
>>                               sg_set_buf(&urb->sg[urb->num_sgs++],
>skb->data, 1);
>>                         }
>>=20
>> I.e. cheat and use the skb->data buffer twice, if that is allowed?=20
>The
>> actual value of the padding byte should not matter, I believe?
>
>That makes me immediately suspect a violation of the DMA rules.

Sounds likely. And it's an ugly hack in any case. Probably not a good i=
dea. Just one of the many random thoughts I should have kept to myself =
:-)


Bj=C3=B8rn=20
