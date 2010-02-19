From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [PATCH 2/5] netlink: store MSG_CMSG_COMPAT flag in
 netlink_skb_parms
Date: Fri, 19 Feb 2010 13:49:24 +0100
Message-ID: <1266583764.3991.56.camel@jlt3.sipsolutions.net>
References: <1266583307-3049-1-git-send-email-fwestphal@astaro.com>
	 <1266583307-3049-3-git-send-email-fwestphal@astaro.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha1"; protocol="application/pgp-signature"; boundary="=-24SLIyNY1MSsFMZCQPYL"
Cc: netdev@vger.kernel.org, Florian Westphal <fw@strlen.de>
To: Florian Westphal <fwestphal@astaro.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from he.sipsolutions.net ([78.46.109.217]:53106 "EHLO
	sipsolutions.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753288Ab0BSMt0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Feb 2010 07:49:26 -0500
In-Reply-To: <1266583307-3049-3-git-send-email-fwestphal@astaro.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-24SLIyNY1MSsFMZCQPYL
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Fri, 2010-02-19 at 13:41 +0100, Florian Westphal wrote:
> From: Florian Westphal <fw@strlen.de>
>=20
> This allows the netlink processing context to determine if the data
> needs any 32 bit fixups.
>=20
> Cc: Johannes Berg <johannes@sipsolutions.net>
> Signed-off-by: Florian Westphal <fw@strlen.de>
> ---
>  changes since v1: change msg_compat to bool.
>=20
>  include/linux/netlink.h  |    1 +
>  net/netlink/af_netlink.c |    3 +++
>  2 files changed, 4 insertions(+), 0 deletions(-)
>=20
> diff --git a/include/linux/netlink.h b/include/linux/netlink.h
> index fde27c0..c094694 100644
> --- a/include/linux/netlink.h
> +++ b/include/linux/netlink.h
> @@ -164,6 +164,7 @@ struct netlink_skb_parms {
>  	__u32			loginuid;	/* Login (audit) uid */
>  	__u32			sessionid;	/* Session id (audit) */
>  	__u32			sid;		/* SELinux security id */
> +	bool			msg_compat;	/* Message needs 32bit fixups */
>  };
> =20
>  #define NETLINK_CB(skb)		(*(struct netlink_skb_parms*)&((skb)->cb))
> diff --git a/net/netlink/af_netlink.c b/net/netlink/af_netlink.c
> index 4910031..5ff97cf 100644
> --- a/net/netlink/af_netlink.c
> +++ b/net/netlink/af_netlink.c
> @@ -1328,6 +1328,9 @@ static int netlink_sendmsg(struct kiocb *kiocb,
> struct socket *sock,
>  	NETLINK_CB(skb).dst_group =3D dst_group;
>  	NETLINK_CB(skb).loginuid =3D audit_get_loginuid(current);
>  	NETLINK_CB(skb).sessionid =3D audit_get_sessionid(current);
> +#ifdef CONFIG_COMPAT_NETLINK_MESSAGES
> +	NETLINK_CB(skb).msg_compat =3D !!(msg->msg_flags & MSG_CMSG_COMPAT);
> +#endif

Can't really decide ... does that ifdef make sense? Or should the
variable be ifdef'ed as well?

johannes

--=-24SLIyNY1MSsFMZCQPYL
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----

iQIcBAABAgAGBQJLfojRAAoJEODzc/N7+Qmam7EP/1n9fA5CLoE09t4NXkxInra3
IGsjgufixUsFVIXLu5IR4U19WeoN8QyrHwao1yUePQk6bmz3mO0QjGa3+bMJgiDv
Oj5yMPxCGqOT0nljQqkHkI4X761QHeh0186c0lnKTvznYAQF3iQ4s1wlYimE9kDj
I+E3aYsp97MyR8qhVbN3b3BxiIdYxbGFyVEoBDJewWSFwGeLcGuQ9qyOMPlA8Nj3
wNHKPLz04IMklKAvyx15DYSNrHDNoRduJHRJxHeEW1YE/1gVTUIFiy/jQgkE0Viy
JY9OPzkIIkxlAz2EHwHBLn9iaG2nnj42VPOqD16uoyQTeuUxCDrcrLdBDfmWNkYd
AAUzGHAzQfmI2OkSTaXHcZIPZn/9yn6fbimg0h6gZjyHLQmHn4DJGWABtAQARCne
NuBzR0nrlgLXCDcG7uLjBupCkIn5YldyMPxATYoTc3huP22+wi6A5fqWATfO7of/
TGO2Vs5T9fXELHsTyeBrK806yPlzMW2m0xnwmPZMV9rO0Vj6jzJyDmmbyNzRwdwL
0xN4BLzhbYfhTCLCvqB7qb2XtszR0KLzASZr9Zu79ZKruZAx4I2YJSUZisLMfaE5
s+9/mq8hDH7Ma45eq/XzRjbgP5pquT5b3hvmyiC1NNwyy+5KD/+4WzHtlMcFxTsD
GSlkgghIWlP3mzkvDXwz
=tIB8
-----END PGP SIGNATURE-----

--=-24SLIyNY1MSsFMZCQPYL--

