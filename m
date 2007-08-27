From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [PATCH net-2.6.24] introduce MAC_FMT/MAC_ARG
Date: Mon, 27 Aug 2007 12:54:09 +0200
Message-ID: <1188212049.6756.18.camel@johannes.berg>
References: <1187808408.4314.15.camel@johannes.berg>
	 <1188086976.18004.5.camel@localhost>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-79nALHRha+O0eZRj2QFr"
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Joe Perches <joe@perches.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from crystal.sipsolutions.net ([195.210.38.204]:60050 "EHLO
	sipsolutions.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753901AbXH0KxE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 27 Aug 2007 06:53:04 -0400
In-Reply-To: <1188086976.18004.5.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-79nALHRha+O0eZRj2QFr
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Sat, 2007-08-25 at 17:09 -0700, Joe Perches wrote:
>=20
> @@ -747,22 +741,15 @@ static int ariadne_rx(struct net_device *dev)
>             skb_copy_to_linear_data(skb, (char *)priv->rx_buff[entry],
> pkt_len);
>             skb->protocol=3Deth_type_trans(skb,dev);
>  #if 0
>  (int)skb->len);
> +{
> +           printk(KERN_DEBUG "RX pkt type 0x%04x"
> +                  " from " MAC_FMT " to " MAC_FMT
> +                  " data 0x%08x len %d\n",
> +                  ((u_short *)skb->data)[6],
> +                  MAC_ARG(((u_char *)skb->data)+6),
> +                  MAC_ARG((u_char *)skb->data),
> +                  (int)skb->data, (int)skb->len);
> +}
>  #endif=20

You could drop the braces since there are no variables there any more.

Thanks for this patch though, I'd have done it otherwise.

I was rereading your original conversion and noticed that it is now
trivial to make the kernel smaller like you originally wanted by doing
something like this

-- define this function somewhere --
print_mac(u8 *mac, char *buf)
{
	sprintf(buf, "%02x:...", mac[0], mac[1], ...);
}
EXPORT_SYMBOL(print_mac)

-- change macros to --
#define MAC_FMT "%s"
#define MAC_ARG(a) ({char __buf[18]; print_mac(a, buf); __buf})

I'm not sure we'd want that, but at the time you said it made the kernel
significantly smaller and I doubt there's a performance problem with it
(who prints mac addresses regularly?)

johannes

--=-79nALHRha+O0eZRj2QFr
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Comment: Johannes Berg (powerbook)

iD8DBQBG0q1R/ETPhpq3jKURAk6QAJ9FmoTAq1bMVCnQ0DiOfxDOUbX9pQCgkgSz
CeewInSSOYBxU0mAvOeSUQ8=
=5Dlg
-----END PGP SIGNATURE-----

--=-79nALHRha+O0eZRj2QFr--

