From: Linus =?utf-8?Q?L=C3=BCssing?= <linus.luessing@web.de>
Subject: Re: bridge is not forwaring ICMP6 neighbor solicitation to
	KVM guest
Date: Tue, 4 Mar 2014 00:03:23 +0100
Message-ID: <20140303230323.GX5090@Linus-Debian>
References: <1566805413.12693479.1393872931017.JavaMail.zimbra@redhat.com>
	<2107636851.12713862.1393876035292.JavaMail.zimbra@redhat.com>
	<20140303212759.GW5090@Linus-Debian> <5314F6D8.2050701@gmail.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="zHDeOHGDnzKksZSU"
Cc: netdev@vger.kernel.org, Florian Westphal <fwestpha@redhat.com>,
	bridge@lists.linux-foundation.org, Jan Stancek <jstancek@redhat.com>
To: Vlad Yasevich <vyasevich@gmail.com>
Return-path: <bridge-bounces@lists.linux-foundation.org>
Content-Disposition: inline
In-Reply-To: <5314F6D8.2050701@gmail.com>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/bridge>,
	<mailto:bridge-request@lists.linux-foundation.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/bridge/>
List-Post: <mailto:bridge@lists.linux-foundation.org>
List-Help: <mailto:bridge-request@lists.linux-foundation.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/bridge>,
	<mailto:bridge-request@lists.linux-foundation.org?subject=subscribe>
Sender: bridge-bounces@lists.linux-foundation.org
Errors-To: bridge-bounces@lists.linux-foundation.org
List-Id: netdev.vger.kernel.org


--zHDeOHGDnzKksZSU
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Mon, Mar 03, 2014 at 04:40:40PM -0500, Vlad Yasevich wrote:
> I did notice a minor issue in the bridge code.  The following
> code:
>        /* Prevent flooding this packet if there is no listener present */
>         if (!ipv6_addr_is_ll_all_nodes(&ip6h->daddr))
>                 BR_INPUT_SKB_CB(skb)->mrouters_only =3D 1;
>=20
>         if (ip6h->nexthdr !=3D IPPROTO_HOPOPTS ||
>             ip6h->payload_len =3D=3D 0)
>                 return 0;
>=20
> will mark most multicast traffic is mrouters_only.  The two
> statement should be probably be reversed.  However, that's shouldn't
> cause the reported problem.

Reversing the order of these two if-clauses would reintroduce the issue
this commit tried to address, I think:
"bridge: prevent flooding IPv6 packets that do not have a listener"

Besides, I don't quite see what minor issue you are refering to,
would you mind being a little more verbose?

Cheers, Linus

PS: mrouters_only has a kind of confusing naming... for
MLD/IGMP packets it means sending to multicast routers only, there
the name fits. But for non-MLD/IGMP packets it means something
else since "bridge: Only flood unregistered groups to routers"
(and I went along with it with "bridge: prevent flooding IPv6 packets
that do not have a listener"), there it means dropping the skb if
there is no router or matching listener.

--zHDeOHGDnzKksZSU
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIcBAEBAgAGBQJTFQo5AAoJELxyPiAAt6UvOCwP/07aEV79emg+L87Gs2TbajYM
kAl9/sysLIfH7hIujdKSbHJTirVEs8l9AysWDCaHl7tDBnQVRnNAhRV3ejDG4kK3
taccDj/66AtJAOl8VEoa6f1OZU2b78YiRPZKeHOaxjkZ/3+jU3UpWL7qqV84Vg4U
2UOc7Xsbc+8+GG8NqKK/5oPnC7WG7U6QlSpxJlcmz681wZ6iDfLDR4Ep1WOi0rpJ
ffgolcFxlANVLOijMR2p3kdmRyup/xBzrdy0G2gFOCwtxW2vV0OXjajK/uPPHv2+
5JtKtS1VlPrKDJ5rIz+BRECMymKS7BtwCDqR+3nfz1/zK/w+GFeMkQuSMQ+oj+Xm
SSbWI7H+wbVQRxGKs6nkpU3QjI4iuZGRYOJ7yYCuBcSdL1/ScVkr2DIYgIIxV35W
upRhenIVZ4H8JELRWbyVeLwcaY5JJrflIAMpCzJJpcGKG9ojknkyP4uX24Sy8T3R
7thPcPqJKy0OheEcbvKQQq1vSKxjlNNRbgYMKF91NxzUqeHLQUhnvW9a89Brdnid
5aYbzNSTB4IGASsNCpq1WwoO7QZKi0SgC4BB4pF3UKEzwywD+IwQ+n2Domhz14Su
7e8BUhqlPVMxo1N6aw2yL/O5lTcQ4b4vB7zvO5l4/Rj3KYpBHrJwFFObNifjTC/P
XHRijXCy/CjRScukeTWT
=Ot+D
-----END PGP SIGNATURE-----

--zHDeOHGDnzKksZSU--
