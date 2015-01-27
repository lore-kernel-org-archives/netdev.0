From: Ben Hutchings <ben@decadent.org.uk>
Subject: Re: [PATCH 1/3] ipv6: Select fragment id during UFO/GSO
	segmentation if not set.
Date: Tue, 27 Jan 2015 02:47:54 +0000
Message-ID: <1422326874.31046.239.camel@decadent.org.uk>
References: <1422283026-27832-1-git-send-email-vyasevic@redhat.com>
	<1422283026-27832-2-git-send-email-vyasevic@redhat.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============9195427152295068374=="
Cc: netdev@vger.kernel.org, edumazet@google.com, mst@redhat.com,
	virtualization@lists.linux-foundation.org
To: Vladislav Yasevich <vyasevich@gmail.com>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <1422283026-27832-2-git-send-email-vyasevic@redhat.com>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/virtualization>,
	<mailto:virtualization-request@lists.linux-foundation.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/virtualization/>
List-Post: <mailto:virtualization@lists.linux-foundation.org>
List-Help: <mailto:virtualization-request@lists.linux-foundation.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/virtualization>,
	<mailto:virtualization-request@lists.linux-foundation.org?subject=subscribe>
Sender: virtualization-bounces@lists.linux-foundation.org
Errors-To: virtualization-bounces@lists.linux-foundation.org
List-Id: netdev.vger.kernel.org


--===============9195427152295068374==
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-0OjldYdcPtHV7rm74m7C"


--=-0OjldYdcPtHV7rm74m7C
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Mon, 2015-01-26 at 09:37 -0500, Vladislav Yasevich wrote:
> If the IPv6 fragment id has not been set and we perform
> fragmentation due to UFO, select a new fragment id.
> When we store the fragment id into skb_shinfo, set the bit
> in the skb so we can re-use the selected id.
> This preserves the behavior of UFO packets generated on the
> host and solves the issue of id generation for packet sockets
> and tap/macvtap devices.
>=20
> This patch moves ipv6_select_ident() back in to the header file. =20
> It also provides the helper function that sets skb_shinfo() frag
> id and sets the bit.
>=20
> It also makes sure that we select the fragment id when doing
> just gso validation, since it's possible for the packet to
> come from an untrusted source (VM) and be forwarded through
> a UFO enabled device which will expect the fragment id.
>=20
> CC: Eric Dumazet <edumazet@google.com>
> Signed-off-by: Vladislav Yasevich <vyasevic@redhat.com>
> ---
>  include/linux/skbuff.h |  3 ++-
>  include/net/ipv6.h     |  2 ++
>  net/ipv6/ip6_output.c  |  4 ++--
>  net/ipv6/output_core.c |  9 ++++++++-
>  net/ipv6/udp_offload.c | 10 +++++++++-
>  5 files changed, 23 insertions(+), 5 deletions(-)
>=20
> diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
> index 85ab7d7..3ad5203 100644
> --- a/include/linux/skbuff.h
> +++ b/include/linux/skbuff.h
> @@ -605,7 +605,8 @@ struct sk_buff {
>  	__u8			ipvs_property:1;
>  	__u8			inner_protocol_type:1;
>  	__u8			remcsum_offload:1;
> -	/* 3 or 5 bit hole */
> +	__u8			ufo_fragid_set:1;
[...]

Doesn't the flag belong in struct skb_shared_info, rather than struct
sk_buff?  Otherwise this looks fine.

Ben.

--=20
Ben Hutchings
When in doubt, use brute force. - Ken Thompson

--=-0OjldYdcPtHV7rm74m7C
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIVAwUAVMb8X+e/yOyVhhEJAQoY7w/+IaOMF0Kpq/DzByIYuziCJlOGgT/eQRgr
BxSCKdNLUJK8dfLrxzjd9rCoC/OUFeCHInkdnteEay8sQrs7hvDCHG4TpoZrd/hx
LS+edT6zhgBmqtkdSghFv9Rt8dR8XjUL1WDwmhKgIk3EKD8vY205D6vmPHZXCU6O
+Xw1h0PTW/j0ISHIPNPWscIdGIs4vw06e3Y4+bp7ToAAQTs8izVds2xgE3EnWLBD
pNhOOX+qT+oUzTe2NP2WoScxXTDo8UyWjgQCoZP01MWL1tov8E6CTCtLbtl45tXN
e8tGQ2ceudJexwxrQ+7R88dIEe6Sj+rgfnI3y4nk1GxK+WOlL1BBoz1RHfekh1X8
yb/NonNr3AnrNKlXYI1xnBsmIxtalqEj2nRZbzf97ENP92LIwdsBEGTvuTBDK64U
yKxNbj0Lb93bfYWuN8XQXOUMjT7uuE6+KPt92PJendKBpDf1CcgZbQOPx1Rj3QYH
mRZsscMbZHpYH0oMvPgrl99OtH4nzLV5/JUuJ2oCszY1GoRxsj8muZyPP9cFt2Ou
AEpRJhq/SLX3tcwadqOw5LHu+Za/L6TpLX2kscTPOFSBxfdcYWwQt/ym6+8c1243
rzUeqtMJ85XTXyNsP19zQAfYTLZkSCmhZY8nre5azVJMGDtFLG782obxuXTwhwps
ZTnFjRF3ID4=
=lmJ7
-----END PGP SIGNATURE-----

--=-0OjldYdcPtHV7rm74m7C--

--===============9195427152295068374==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
Virtualization mailing list
Virtualization@lists.linux-foundation.org
https://lists.linuxfoundation.org/mailman/listinfo/virtualization
--===============9195427152295068374==--
