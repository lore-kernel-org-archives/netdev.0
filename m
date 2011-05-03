From: David Hill <david.hill-+VOaU5BgciZBDgjK7y7TUQ@public.gmane.org>
Subject: RE: [PATCH] ipheth.c: Enable IP header alignment
Date: Tue, 3 May 2011 13:18:39 -0400
Message-ID: <710D4D6CE160654C87478D18385BB9971BE3FDCA46@MDC-MAIL-CMS01.ubisoft.org>
References: <1304264799.2833.82.camel@localhost>
 <1304364912-15444-1-git-send-email-agimenez@sysvalve.es>
 <1304370274.2833.192.camel@localhost>
 <20110503165751.GA6566@bart.evergreen.loc>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"dgiagio-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org" <dgiagio-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	"dborca-/E1597aS9LQAvxtiuMwx3w@public.gmane.org" <dborca-/E1597aS9LQAvxtiuMwx3w@public.gmane.org>,
	"davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	"pmcenery-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org" <pmcenery-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	"open list:USB SUBSYSTEM" <linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"open list:NETWORKING DRIVERS" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: =?iso-8859-1?Q?L=2E_Alberto_Gim=E9nez?= <agimenez-lqZFv/KUvpAxAGwisGp4zA@public.gmane.org>,
	Ben Hutchings <bhutchings-s/n/eUQHGBpZroRs9YW3xA@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20110503165751.GA6566-vFZw08TITM7wxNmfbb4FQRs6BjWItJ1b@public.gmane.org>
Content-Language: en-US
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Maybe I can help on this part.

Git ?

I'm using ubuntu natty ... The part  I'm not sure of is , do I patch ub=
untu's kernel or I start from scratch?


-----Original Message-----
=46rom: L. Alberto Gim=E9nez [mailto:agimenez-lqZFv/KUvpAxAGwisGp4zA@public.gmane.org]=20
Sent: 3 mai 2011 12:58
To: Ben Hutchings
Cc: linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org; dgiagio-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org; dborca-/E1597aS9LQAvxtiuMwx3w@public.gmane.org; =
davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org; pmcenery-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org; David Hill; open list:USB SUBS=
YSTEM; open list:NETWORKING DRIVERS
Subject: Re: [PATCH] ipheth.c: Enable IP header alignment

On Mon, May 02, 2011 at 10:04:34PM +0100, Ben Hutchings wrote:
> So this was using NET_IP_ALIGN as an offset into the URB.  Which was
> totally bogus, as its value has long been architecture-dependent.  Th=
e
> code is also claiming to put len bytes but only copying len - delta.
>=20
> The correct code would be something like:
>=20
> 	if (urb->actual_length <=3D IPHETH_IP_ALIGN) {
> 		dev->net->stats.rx_length_errors++;
> 		return;
> 	}
> 	len =3D urb->actual_length - IPHETH_IP_ALIGN;
> 	buf =3D urb->transfer_buffer + IPHETH_IP_ALIGN;
> =09
> 	dev_alloc_skb(len);
> 	...
> 	memcpy(skb_put(skb, len), buf, len);

Thanks for the response Ben.

I can try to change the code, but I don't own the device anymore. Chang=
ing the
code without being able to test it would be walking blindfolded :-/

If upstrem (everyone involved is in CC) can't do it, I can submit the c=
hanges
advised by Ben, but I can't warantee anything beyond successful compila=
tion. I
don't think that it would be acceptable here.

Regards,
--=20
L. Alberto Gim=E9nez
JabberID agimenez-eu7EghD4TOHJ13y34KW5H97lo5+wdyHW@public.gmane.org
GnuPG key ID 0x3BAABDE1
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
