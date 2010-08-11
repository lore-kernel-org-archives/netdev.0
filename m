From: Matthieu CASTET <matthieu.castet-ITF29qwbsa/QT0dZR+AlfA@public.gmane.org>
Subject: Re: Problem with non aligned DMA in usbnet on ARM
Date: Wed, 11 Aug 2010 11:59:21 +0200
Message-ID: <4C627479.4060400@parrot.com>
References: <AANLkTi=ycg=adcizNWKMCb7EdfDANM=6Es7r_gF1LbhV@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-usb <linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org"
	<linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org>
To: Martin Fuzzey <mfuzzey-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <AANLkTi=ycg=adcizNWKMCb7EdfDANM=6Es7r_gF1LbhV-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hi,

Martin Fuzzey a =E9crit :
> Hi all,

> So what is the correct fix for this problem?
> The options seem to be:
> 1) Remove skb_reserve() from usbnet
> But this will cause the ip header to be non aligned on platforms that
> don't have the DMA alignment requirement.
And cause lot's of unaligned access for the IP stack. This will slow=20
down arm platform...

>=20
> 2) Define NET_IP_ALIGN to 0 for ARM
> Seems a bit intrusive to me.
Again this will generate lot's of unaligned access.
>=20
> 3) Change the HCD to copy if not aligned
> I'd like to avoid that.
>=20
> 4) Change usbnet to use seperate buffers for the usb side and skb.
> Copy between them so both remain aligned
> Seems unlikely that the gain further up the stack from ensuring the i=
p
> header is aligned will offset the cost of the copy.
>=20
> Any ideas?
I got the same problem on the gadget side :=20
http://article.gmane.org/gmane.linux.usb.general/28700

A solution could be the hcd driver to tell it doesn't support unaligned=
=20
transfert and in this case the usb stack/usb driver align it.

It is best to solve in usb driver, because for example in Asix case the=
=20
driver already do copy (see asix_rx_fixup/asix_tx_fixup).


Matthieu

PS : what hcd driver do you use ?
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
