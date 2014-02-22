From: Ben Hutchings <ben@decadent.org.uk>
Subject: Re: [PATCH net-next V1 0/3] net/mlx4: Mellanox driver update
 01-01-2014
Date: Sat, 22 Feb 2014 01:33:18 +0000
Message-ID: <1393032798.15717.85.camel@deadeye.wl.decadent.org.uk>
References: <1392814684-2129-1-git-send-email-amirv@mellanox.com>
	 <20140219.165049.1684072721398326970.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-GYAMBsBE+1QKON8plDU2"
Cc: amirv@mellanox.com, netdev@vger.kernel.org, yevgenyp@mellanox.com,
	ogerlitz@mellanox.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:55567 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753541AbaBVBd1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Feb 2014 20:33:27 -0500
In-Reply-To: <20140219.165049.1684072721398326970.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-GYAMBsBE+1QKON8plDU2
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Wed, 2014-02-19 at 16:50 -0500, David Miller wrote:
> From: Amir Vadai <amirv@mellanox.com>
> Date: Wed, 19 Feb 2014 14:58:01 +0200
>=20
> > V0 of this patch was sent before previous net-next got closed, and
> > now we would like to resume it.
> >=20
> > Yuval has reworked the affinity hint patch, according to Ben's comments=
. The
> > patch was actually rewritten.
> > After a discussion with Yuval Mintz, use of netif_get_num_default_rss_q=
ueues()
> > is not reverted, but done in the right place. Instead of limiting the n=
umber of
> > IRQ's for the driver it will limit the number of queues in RSS.
> >=20
> > Patchset was applied and tested against commit: cb6e926 "ipv6:fix check=
patch
> > errors with assignment in if condition"
>=20
> Influencing IRQs to be allocated on the same NUMA code as the one where
> the card resides doesn't sound like an mlx4 specific desire to me.
>=20
> Other devices, both networking and non-networking, probably might like
> that as well.
>=20
> Therefore doing this by hand in a specific driver doesn't seem
> appropriate at all.

Handling network traffic only on the local node can be really good on
recent Intel processors, where DMA writes will usually go into cache on
the local node.  But on other architectures, AMD processors, older Intel
processors... I don't think there's such a big difference.  Also, where
the system and device implement PCIe Transaction Processing Hints, DMA
writes to cache should work on all nodes (following interrupt
affinity)... in theory.

So this sort of policy not only shouldn't be implemented in specific
drivers, but also ought to be configurable.

Ben.

--=20
Ben Hutchings
I haven't lost my mind; it's backed up on tape somewhere.

--=-GYAMBsBE+1QKON8plDU2
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIVAwUAUwf+Xue/yOyVhhEJAQpCiBAAltr6mVrnmLoGiSAehiQP32oUOuGI04SQ
6t3V9yIxZgipJLmhZzwE0mdEFEMhh9GJVArkiB/KD9mvOOjgCxfOO1nQVV5d3ya2
4rdXqhzYklyGu1td+sWJte3FqiIEURqrzvypPbrX3j2W5Ujm7b9aalTa/dJJDd2k
4o+nI3mlrGuOXfNnsrtRAdyE162OHa/MEmA9xcVbu10marSLi0ZrUGRa/Sj/WGh6
pBNd3A9BrnSpmlf1lK2TxJ8x1pSZ+ilTs4P4a2CJLMo05Y6Wk9DvIJfptX+hU/bK
efLPHfEZCsvOV2HxWoU6/0Q4e8OV09wpHmggXoFdlB3XK4qmfKKDnt8SZjKcexnS
pr2IpVoINuU8iVAyhPRfG+6edEnYxLfEZvDsBY2ZHGCotLNApPDQikeQdnYG3g2G
rRvHQn0SHwnmSCSxLuPdvXm9qoTGkChIYWNeFzM3pssMcOZOlT0U77BQ841oPqL1
ihne/x3Jh3nTgoHplgEykpl30kTAmUUg5epYAEDLbMEFOnPSV+zJ9NrrGILdk6ay
hddtlMrbdua3eArJAKsHRm1NfTeuca5ZhKHJPhsLdeqfucFlWBtGno27jl1Iwtrc
cL6j96pbmQgcGZPVC4snQ+vKAVQ1yDdQprlVbSnyQN88uBDo0Au7AuocgTRvt7Vf
h2+UlDwe+fs=
=+vSL
-----END PGP SIGNATURE-----

--=-GYAMBsBE+1QKON8plDU2--
