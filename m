From: "Rustad, Mark D" <mark.d.rustad@intel.com>
Subject: Re: [PATCH net-next 09/13] vxlan: provide access function for vxlan
 socket address family
Date: Tue, 25 Aug 2015 00:34:18 +0000
Message-ID: <E8BB0745-6652-4539-BE59-6E0DD0977B2F@intel.com>
References: <cover.1439929916.git.jbenc@redhat.com>
 <a07e8ad2f7cfc3153d569a2b3f366bf17b2f348a.1439929916.git.jbenc@redhat.com>
Mime-Version: 1.0
Content-Type: multipart/signed;
	boundary="Apple-Mail=_4B838F2A-90D8-4DF0-8A2E-18A15FA469A2";
	protocol="application/pgp-signature"; micalg=pgp-sha256
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Thomas Graf <tgraf@suug.ch>
To: Jiri Benc <jbenc@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([134.134.136.65]:64540 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754209AbbHYAeU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 24 Aug 2015 20:34:20 -0400
In-Reply-To: <a07e8ad2f7cfc3153d569a2b3f366bf17b2f348a.1439929916.git.jbenc@redhat.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--Apple-Mail=_4B838F2A-90D8-4DF0-8A2E-18A15FA469A2
Content-Transfer-Encoding: quoted-printable
Content-Type: text/plain;
	charset=us-ascii

> On Aug 18, 2015, at 1:33 PM, Jiri Benc <jbenc@redhat.com> wrote:
>=20
> Signed-off-by: Jiri Benc <jbenc@redhat.com>
> ---
> drivers/net/vxlan.c | 8 ++++----
> include/net/vxlan.h | 5 +++++
> 2 files changed, 9 insertions(+), 4 deletions(-)
>=20
> diff --git a/drivers/net/vxlan.c b/drivers/net/vxlan.c
> index e4b8ab63d0fa..d5ca1d7e0b81 100644
> --- a/drivers/net/vxlan.c
> +++ b/drivers/net/vxlan.c
> @@ -236,7 +236,7 @@ static struct vxlan_sock *vxlan_find_sock(struct =
net *net, sa_family_t family,
>=20
> 	hlist_for_each_entry_rcu(vs, vs_head(net, port), hlist) {
> 		if (inet_sk(vs->sock->sk)->inet_sport =3D=3D port &&
> -		    inet_sk(vs->sock->sk)->sk.sk_family =3D=3D family &&
> +		    vxlan_get_sk_family(vs) =3D=3D family &&
> 		    vs->flags =3D=3D flags)
> 			return vs;
> 	}
> @@ -625,7 +625,7 @@ static void vxlan_notify_add_rx_port(struct =
vxlan_sock *vs)
> 	struct net_device *dev;
> 	struct sock *sk =3D vs->sock->sk;
> 	struct net *net =3D sock_net(sk);
> -	sa_family_t sa_family =3D sk->sk_family;
> +	sa_family_t sa_family =3D vxlan_get_sk_family(vs);
> 	__be16 port =3D inet_sk(sk)->inet_sport;
> 	int err;
>=20
> @@ -650,7 +650,7 @@ static void vxlan_notify_del_rx_port(struct =
vxlan_sock *vs)
> 	struct net_device *dev;
> 	struct sock *sk =3D vs->sock->sk;
> 	struct net *net =3D sock_net(sk);
> -	sa_family_t sa_family =3D sk->sk_family;
> +	sa_family_t sa_family =3D vxlan_get_sk_family(vs);
> 	__be16 port =3D inet_sk(sk)->inet_sport;
>=20
> 	rcu_read_lock();
> @@ -2390,7 +2390,7 @@ void vxlan_get_rx_port(struct net_device *dev)
> 	for (i =3D 0; i < PORT_HASH_SIZE; ++i) {
> 		hlist_for_each_entry_rcu(vs, &vn->sock_list[i], hlist) {
> 			port =3D inet_sk(vs->sock->sk)->inet_sport;
> -			sa_family =3D vs->sock->sk->sk_family;
> +			sa_family =3D vxlan_get_sk_family(vs);
> 			dev->netdev_ops->ndo_add_vxlan_port(dev, =
sa_family,
> 							    port);
> 		}
> diff --git a/include/net/vxlan.h b/include/net/vxlan.h
> index e4534f1b2d8c..43677e6b9c43 100644
> --- a/include/net/vxlan.h
> +++ b/include/net/vxlan.h
> @@ -241,3 +241,8 @@ static inline void vxlan_get_rx_port(struct =
net_device *netdev)
> }
> #endif
> #endif
> +
> +static inline unsigned short vxlan_get_sk_family(struct vxlan_sock =
*vs)
> +{
> +	return vs->sock->sk->sk_family;
> +}

This causes build problems because vxlan_get_sk_family is not inside the =
#endif
protecting the file for multiple inclusion. Please put =
vxlan_get_sk_family
inside the last #endif.

--
Mark Rustad, Networking Division, Intel Corporation


--Apple-Mail=_4B838F2A-90D8-4DF0-8A2E-18A15FA469A2
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment; filename="signature.asc"
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Message signed with OpenPGP using GPGMail

-----BEGIN PGP SIGNATURE-----
Comment: GPGTools - http://gpgtools.org

iQIcBAEBCAAGBQJV27gJAAoJEDwO/+eO4+5uYI0P/i7+9aVGiKNL1NrwddGpjYET
vOLdI9KqcLoGwBqHWtMkbeZi6uDdNyCm9+ZKp4wGFMfAZc4J5muODCO/1RQSUCi0
d0yNwTd3imMVQ86oTTHGKEfVINoZcwToc3PCmPg0AMKhQTeDT9Bwz4MbsSVrHS9s
Kb5EWSZ+jqr31EgYsgTkqeUntJyTZfLlIiu4ns28MzfUhDKTDmO36zLodQCRF7a1
zSNMZTfho1Zf8nQSX6Sqvi04LZ5QyX0PxxF+8QpEENceGY7yEpmdCCLpwUITy0NH
1mUcssdubrJZCjMRde8DqV8B/SwGiatLIY5kGQEcMB+dxpApwkIj/CrJF7Vx8GzI
Fq3VwRGMFVIFYZykTTI9jik+Pex6jP6JCOjXPWV+/VvUqgq+UKRsDmpnXZwONs9w
veicz4EcW4fNDSNkagOeNtT8dXVnuvhgU/bFIVqxuVErv6c9mKIiP52ayBxZjgDS
JuLt9PVvlUT1T3Yiync/wfDEUzxM58Q2ruV3GyZxcYENj19GI5CU2CkJEfGkyV8E
54KXR4hPYcgtS4YzqWF6gLknXgIQkENQJwTY1J7QrYeqdYGan2YBnG3hPMSxWndf
Muwx3nhky4E0aYDSvoVSk4qoV4RYL0WJt6AV8Gti3IdvB96x+eDe1X/JwcOYiBl2
/2Zl9I05Sw2sZU6jNP9B
=ZoKx
-----END PGP SIGNATURE-----

--Apple-Mail=_4B838F2A-90D8-4DF0-8A2E-18A15FA469A2--
