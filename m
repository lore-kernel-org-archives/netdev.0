From: Antonio Quartulli <antonio-x4xJYDvStAgysxA8WJXlww@public.gmane.org>
Subject: Re: [PATCH linux-next] net: batman-adv: use
 "__packed __aligned(2)" for each structure instead of "__packed(2)" region
Date: Sat, 18 Jan 2014 14:03:26 +0100
Message-ID: <52DA7B9E.4040202@meshcoding.com>
References: <52DA65F4.5070501@gmail.com>
Reply-To: The list for a Better Approach To Mobile Ad-hoc Networking
 <b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
 protocol="application/pgp-signature";
 boundary="AaCOvu4D3243PQ4HrkpQnqlPmNQSCN3hJ"
Cc: James Hogan <james.hogan-1AXoQHu6uovQT0dZR+AlfA@public.gmane.org>, mareklindner-rVWd3aGhH2z5bpWLKbzFeg@public.gmane.org,
 netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org,
 "linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
 linux-metag-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Chen Gang <gang.chen.5i5j-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <b.a.t.m.a.n-bounces-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
In-Reply-To: <52DA65F4.5070501-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
List-Unsubscribe: <https://lists.open-mesh.org/mm/options/b.a.t.m.a.n>,
 <mailto:b.a.t.m.a.n-request-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.open-mesh.org/pipermail/b.a.t.m.a.n/>
List-Post: <mailto:b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
List-Help: <mailto:b.a.t.m.a.n-request-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org?subject=help>
List-Subscribe: <https://lists.open-mesh.org/mm/listinfo/b.a.t.m.a.n>,
 <mailto:b.a.t.m.a.n-request-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org?subject=subscribe>
Errors-To: b.a.t.m.a.n-bounces-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org
Sender: "B.A.T.M.A.N" <b.a.t.m.a.n-bounces-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--AaCOvu4D3243PQ4HrkpQnqlPmNQSCN3hJ
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

On 18/01/14 12:31, Chen Gang wrote:
> Unfortunately, not all compilers assumes the structures within a pack
> region also need be packed (e.g. metag), so need add a pack explicitly
> to satisfy all compilers.
>=20
> The related error (under metag with allmodconfig):
>=20
>     MODPOST 2952 modules
>   ERROR: "__compiletime_assert_431" [net/batman-adv/batman-adv.ko] unde=
fined!
>   ERROR: "__compiletime_assert_432" [net/batman-adv/batman-adv.ko] unde=
fined!
>   ERROR: "__compiletime_assert_429" [net/batman-adv/batman-adv.ko] unde=
fined!
>   ERROR: "__compiletime_assert_428" [net/batman-adv/batman-adv.ko] unde=
fined!
>   ERROR: "__compiletime_assert_423" [net/batman-adv/batman-adv.ko] unde=
fined!
>=20
>=20
> Signed-off-by: Chen Gang <gang.chen.5i5j-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>

David, what do you think about this change?


Can "__packed __aligned(2)" generate a different structure padding than
"#pragma pack(2)" ?

I am not really sure about the difference between the two. But if we
have the possibility that the padding may change then this patch should
go into net, otherwise we will have a protocol compatibility problem
between 3.13 and 3.14.


Cheers,

> ---
>  net/batman-adv/packet.h | 16 ++++++----------
>  1 file changed, 6 insertions(+), 10 deletions(-)
>=20
> diff --git a/net/batman-adv/packet.h b/net/batman-adv/packet.h
> index 0a381d1..9206b48 100644
> --- a/net/batman-adv/packet.h
> +++ b/net/batman-adv/packet.h
> @@ -154,7 +154,6 @@ enum batadv_tvlv_type {
>  	BATADV_TVLV_ROAM	=3D 0x05,
>  };
> =20
> -#pragma pack(2)
>  /* the destination hardware field in the ARP frame is used to
>   * transport the claim type and the group id
>   */
> @@ -162,8 +161,7 @@ struct batadv_bla_claim_dst {
>  	uint8_t magic[3];	/* FF:43:05 */
>  	uint8_t type;		/* bla_claimframe */
>  	__be16 group;		/* group id */
> -};
> -#pragma pack()
> +} __packed __aligned(2);
> =20
>  /**
>   * struct batadv_ogm_packet - ogm (routing protocol) packet
> @@ -281,7 +279,6 @@ struct batadv_icmp_packet_rr {
>   * misalignment of the payload after the ethernet header. It may also =
lead to
>   * leakage of information when the padding it not initialized before s=
ending.
>   */
> -#pragma pack(2)
> =20
>  /**
>   * struct batadv_unicast_packet - unicast packet for network payload
> @@ -300,7 +297,7 @@ struct batadv_unicast_packet {
>  	/* "4 bytes boundary + 2 bytes" long to make the payload after the
>  	 * following ethernet header again 4 bytes boundary aligned
>  	 */
> -};
> +}  __packed __aligned(2);
> =20
>  /**
>   * struct batadv_unicast_4addr_packet - extended unicast packet
> @@ -316,7 +313,7 @@ struct batadv_unicast_4addr_packet {
>  	/* "4 bytes boundary + 2 bytes" long to make the payload after the
>  	 * following ethernet header again 4 bytes boundary aligned
>  	 */
> -};
> +}  __packed __aligned(2);
> =20
>  /**
>   * struct batadv_frag_packet - fragmented packet
> @@ -347,7 +344,7 @@ struct batadv_frag_packet {
>  	uint8_t orig[ETH_ALEN];
>  	__be16  seqno;
>  	__be16  total_size;
> -};
> +}  __packed __aligned(2);
> =20
>  /**
>   * struct batadv_bcast_packet - broadcast packet for network payload
> @@ -368,7 +365,7 @@ struct batadv_bcast_packet {
>  	/* "4 bytes boundary + 2 bytes" long to make the payload after the
>  	 * following ethernet header again 4 bytes boundary aligned
>  	 */
> -};
> +}  __packed __aligned(2);
> =20
>  /**
>   * struct batadv_coded_packet - network coded packet
> @@ -404,9 +401,8 @@ struct batadv_coded_packet {
>  	uint8_t  second_orig_dest[ETH_ALEN];
>  	__be32   second_crc;
>  	__be16   coded_len;
> -};
> +}  __packed __aligned(2);
> =20
> -#pragma pack()
> =20
>  /**
>   * struct batadv_unicast_tvlv - generic unicast packet with tvlv paylo=
ad
>=20


--=20
Antonio Quartulli


--AaCOvu4D3243PQ4HrkpQnqlPmNQSCN3hJ
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.22 (GNU/Linux)

iQIcBAEBCAAGBQJS2nuiAAoJEEKTMo6mOh1Vv4oP/Rskco/HiL6QlbP3mDcqaMol
lqOrZH3O0r2Gc2FKVzrjqMX2dX08i8XkxtSSwVdtPeCQ6R7doGbOarFk+jTazhx6
lxyUpX/sA2vvGrffx7jrRuEuZJKmMghvJ+QNFjbAlcL421Y49vtN5mNIDIpWrOSG
UcbM4UzFbikE9SAnISinwhQSNe0YYWp+V/H+VOcEZ0R9fGtqJBFzjOHYRo20IcNx
qwBOyMH/ANirFruxvNofuux4OzVlc2SXabFdm+0lQQplSQWRE7tmrBclvOnBJPd/
g1JfH39UorL8ubcqFvayoQ1GPeNaMFBKMLECIC6tFlrEj5RGPUHArdpKWbvA9ZTn
qEn5l2u08MPQnei9LLYaK9poCZH8HoGkjAe+Pa0W05baFK8Ndm5sr3slyeLf0xkH
jfbG+gUtxxjRi7nr+uK9mkeWRHBlcyAaauvgf+FCtaPuUb90YlHueX0cEfJgKabt
ZbmekjIjm1m03gT7lgXEOEFtHyXqDFoZ0xUbkVk5LtnsTxFEQc2zAObQtgJAbfVh
d2bMrVC5fvuo74/qyxB5GdOPi6ofZULTqkjYB28JVE9joMGbPPJSP/Mcfe/hLI1Z
beHQvd5tfWO0Lj8a0S91GCUNUOGMi7kjgFwSYkrbHJc7Y5VKbBP8gDlSeP9+aHA4
pqRt750w0apFrpfpTB1o
=jvi1
-----END PGP SIGNATURE-----

--AaCOvu4D3243PQ4HrkpQnqlPmNQSCN3hJ--
