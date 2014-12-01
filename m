From: Stefan Bader <stefan.bader@canonical.com>
Subject: Re: [Xen-devel] [PATCH] xen-netfront: Fix handling packets on compound
 pages with skb_linearize
Date: Mon, 01 Dec 2014 09:55:24 +0100
Message-ID: <547C2CFC.7060908@canonical.com>
References: <1407778343-13622-1-git-send-email-zoltan.kiss@citrix.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha512;
 protocol="application/pgp-signature";
 boundary="s150fMuQq0LSLSF52s9aqbJl7oRUV2dRv"
Cc: Wei Liu <wei.liu2@citrix.com>,
	Ian Campbell <Ian.Campbell@citrix.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	Paul Durrant <paul.durrant@citrix.com>,
	xen-devel@lists.xenproject.org
To: Zoltan Kiss <zoltan.kiss@citrix.com>,
	Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>,
	Boris Ostrovsky <boris.ostrovsky@oracle.com>,
	David Vrabel <david.vrabel@citrix.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1407778343-13622-1-git-send-email-zoltan.kiss@citrix.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--s150fMuQq0LSLSF52s9aqbJl7oRUV2dRv
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: quoted-printable

On 11.08.2014 19:32, Zoltan Kiss wrote:
> There is a long known problem with the netfront/netback interface: if t=
he guest
> tries to send a packet which constitues more than MAX_SKB_FRAGS + 1 rin=
g slots,
> it gets dropped. The reason is that netback maps these slots to a frag =
in the
> frags array, which is limited by size. Having so many slots can occur s=
ince
> compound pages were introduced, as the ring protocol slice them up into=

> individual (non-compound) page aligned slots. The theoretical worst cas=
e
> scenario looks like this (note, skbs are limited to 64 Kb here):
> linear buffer: at most PAGE_SIZE - 17 * 2 bytes, overlapping page bound=
ary,
> using 2 slots
> first 15 frags: 1 + PAGE_SIZE + 1 bytes long, first and last bytes are =
at the
> end and the beginning of a page, therefore they use 3 * 15 =3D 45 slots=

> last 2 frags: 1 + 1 bytes, overlapping page boundary, 2 * 2 =3D 4 slots=

> Although I don't think this 51 slots skb can really happen, we need a s=
olution
> which can deal with every scenario. In real life there is only a few sl=
ots
> overdue, but usually it causes the TCP stream to be blocked, as the ret=
ry will
> most likely have the same buffer layout.
> This patch solves this problem by linearizing the packet. This is not t=
he
> fastest way, and it can fail much easier as it tries to allocate a big =
linear
> area for the whole packet, but probably easier by an order of magnitude=
 than
> anything else. Probably this code path is not touched very frequently a=
nyway.
>=20
> Signed-off-by: Zoltan Kiss <zoltan.kiss@citrix.com>
> Cc: Wei Liu <wei.liu2@citrix.com>
> Cc: Ian Campbell <Ian.Campbell@citrix.com>
> Cc: Paul Durrant <paul.durrant@citrix.com>
> Cc: netdev@vger.kernel.org
> Cc: linux-kernel@vger.kernel.org
> Cc: xen-devel@lists.xenproject.org

This does not seem to be marked explicitly as stable. Has someone already=
 asked
David Miller to put it on his stable queue? IMO it qualifies quite well a=
nd the
actual change should be simple to pick/backport.

-Stefan

>=20
> diff --git a/drivers/net/xen-netfront.c b/drivers/net/xen-netfront.c
> index 055222b..23359ae 100644
> --- a/drivers/net/xen-netfront.c
> +++ b/drivers/net/xen-netfront.c
> @@ -628,9 +628,10 @@ static int xennet_start_xmit(struct sk_buff *skb, =
struct net_device *dev)
>  	slots =3D DIV_ROUND_UP(offset + len, PAGE_SIZE) +
>  		xennet_count_skb_frag_slots(skb);
>  	if (unlikely(slots > MAX_SKB_FRAGS + 1)) {
> -		net_alert_ratelimited(
> -			"xennet: skb rides the rocket: %d slots\n", slots);
> -		goto drop;
> +		net_dbg_ratelimited("xennet: skb rides the rocket: %d slots, %d byte=
s\n",
> +				    slots, skb->len);
> +		if (skb_linearize(skb))
> +			goto drop;
>  	}
> =20
>  	spin_lock_irqsave(&queue->tx_lock, flags);
>=20
> _______________________________________________
> Xen-devel mailing list
> Xen-devel@lists.xen.org
> http://lists.xen.org/xen-devel
>=20



--s150fMuQq0LSLSF52s9aqbJl7oRUV2dRv
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIcBAEBCgAGBQJUfC0OAAoJEOhnXe7L7s6jxHEQALgipbF0gVIGN6YUt6utLg5b
QJ8obUcc1Ixkj8sjx3zzngSS2uViTjjLRKGg7LSEDxFkflvcytjPgImqv/xKOE5r
s7teGzYSy1E6qFgoTCHXy80wgWhrFP26Y5AjmFa4x+nFMAiMFE/BEFHj82XC9sZ1
vhtYugM9HsJwUhh4qWYPLltZyGWIzOgVzs3X1R/pE1VL8kMaLvlgNqZUHUv51bOo
zSmUOqzbqnPxWw4E8tLxVwL3e9QckjJ+8YFGK7ozW3xM4lmgKrya7JMUOB3EnrFQ
aZ1pvnnfXZUO1ScelgFNaxEg9cCVhzxdaM91RrbRb64p0DD6ToqZDkCLcOJKezzg
qz/gj4QqmXFE7ZlOe5HV0nSHFeIb6hnObO7Yi2D35nIceTaDtRRmB8Z2659b3Gex
F9jtoJ1kejrFaSQMoEnywDMyyn+oL0KvhDcIZOd9uzuZ2Nva8+Xpabc1Ihml7vUo
DYg6em1xyrjnf3TznDX+eC1ZyE1IPtZLacDFcAahFSBjhW/seYBqUnEFyccEDofu
OyMqwoC9R6E+Xj04VYZUOLaXMP7EMAnzuMHZpLrlwDXL8+791hFF6QG417KzYM2B
0++nkvypnif2QVdakursAzcM+IEbSEpoys0QvRjOEVnPwoSkWptqLXWRfpW4hsv4
O+GqOZhH4RVSE4cYcrl1
=Ec0I
-----END PGP SIGNATURE-----

--s150fMuQq0LSLSF52s9aqbJl7oRUV2dRv--
