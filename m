From: Petr Pisar <ppisar@redhat.com>
Subject: Re: [PATCH] Do not listen if rtnl_send() fails in ip link
 iplink_have_newlink() test
Date: Thu, 2 Jan 2014 08:42:57 +0100
Message-ID: <20140102074257.GA1637@dhcp-0-146.brq.redhat.com>
References: <20131211105749.1ee87844@nehalam.linuxnetplumber.net>
 <1386832705-3101-1-git-send-email-ppisar@redhat.com>
 <20131220082107.0467d57c@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
	protocol="application/pgp-signature"; boundary="T4sUOijqQbZv57TR"
Cc: Stephen Hemminger <stephen@networkplumber.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:9474 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750800AbaABHnE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 2 Jan 2014 02:43:04 -0500
Content-Disposition: inline
In-Reply-To: <20131220082107.0467d57c@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--T4sUOijqQbZv57TR
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Fri, Dec 20, 2013 at 08:21:07AM -0800, Stephen Hemminger wrote:
> I took your idea and enhanced it to all of iproute2 by doing the followin=
g:
>=20
> From c4b6330a3a033bd9c9b0664c5f844493137ae599 Mon Sep 17 00:00:00 2001
> From: Stephen Hemminger <stephen@networkplumber.org>
> Date: Fri, 20 Dec 2013 08:15:02 -0800
> Subject: [PATCH] check return value of rtnl_send and related functions
> MIME-Version: 1.0
> Content-Type: text/plain; charset=3DUTF-8
> Content-Transfer-Encoding: 8bit
>=20
> Use warn_unused_result to enforce checking return value of rtnl_send,
> and fix where the errors are.
>=20
[...]
> diff --git a/ip/iplink.c b/ip/iplink.c
> index 58b6c20..e0c14e6 100644
> --- a/ip/iplink.c
> +++ b/ip/iplink.c
> @@ -178,7 +178,10 @@ static int iplink_have_newlink(void)
>  		req.n.nlmsg_type =3D RTM_NEWLINK;
>  		req.i.ifi_family =3D AF_UNSPEC;
> =20
> -		rtnl_send(&rth, &req.n, req.n.nlmsg_len);
> +		if (rtnl_send(&rth, &req.n, req.n.nlmsg_len) < 0) {
> +			perror("request send failed");
> +			exit(1);
> +		}
>  		rtnl_listen(&rth, accept_msg, NULL);
>  	}
>  	return have_rtnl_newlink;

This one exits instead of falling back to IOCTL. iplink_have_newlink() is
called even from iplink_usage(). This even prevents from printing usage.

I think failure in this very place should be treated as I suggested.

-- Petr

--T4sUOijqQbZv57TR
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.22 (GNU/Linux)

iF4EABEIAAYFAlLFGIEACgkQEsnFx2fG+qKzdAD/WJOviG3b0q7Pn5fVmmM0q2/C
pi1DPPp+Sf1RexWjC7ABAIDdU+C8UiLcARChw+g93WXxHTQsmU+cOD+88X0Ibz2q
=Ab+p
-----END PGP SIGNATURE-----

--T4sUOijqQbZv57TR--
