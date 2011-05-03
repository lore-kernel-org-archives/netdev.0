From: =?iso-8859-1?Q?L=2E_Alberto_Gim=E9nez?= <agimenez@sysvalve.es>
Subject: Re: [PATCH] ipheth.c: Enable IP header alignment
Date: Tue, 3 May 2011 18:57:51 +0200
Message-ID: <20110503165751.GA6566@bart.evergreen.loc>
References: <1304264799.2833.82.camel@localhost>
 <1304364912-15444-1-git-send-email-agimenez@sysvalve.es>
 <1304370274.2833.192.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-kernel@vger.kernel.org, dgiagio@gmail.com, dborca@yahoo.com,
	davem@davemloft.net, pmcenery@gmail.com, david.hill@ubisoft.com,
	"open list:USB SUBSYSTEM" <linux-usb@vger.kernel.org>,
	"open list:NETWORKING DRIVERS" <netdev@vger.kernel.org>
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1304370274.2833.192.camel@localhost>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

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
JabberID agimenez@jabber.sysvalve.es
GnuPG key ID 0x3BAABDE1
