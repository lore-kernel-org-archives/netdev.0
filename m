From: Thomas Haller <thaller@redhat.com>
Subject: Re: [patch net-next RFC v2 2/2] ipv6 addrconf: introduce
 IFA_F_MANAGETEMPADDR to tell kernel to manage temporary addresses
Date: Wed, 27 Nov 2013 14:02:53 +0100
Message-ID: <1385557373.13113.12.camel@rh1.brq.redhat.com>
References: <1384857809-6573-1-git-send-email-jiri@resnulli.us>
	 <1384857809-6573-3-git-send-email-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha1"; protocol="application/pgp-signature";
	boundary="=-0zJe30tnzO+8C0w4qXNJ"
Cc: netdev@vger.kernel.org, davem@davemloft.net, kuznet@ms2.inr.ac.ru,
	jmorris@namei.org, yoshfuji@linux-ipv6.org, kaber@trash.net,
	stephen@networkplumber.org, hannes@stressinduktion.org,
	vyasevich@gmail.com, dcbw@redhat.com, David.Laight@ACULAB.COM
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:58365 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751235Ab3K0NEJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 27 Nov 2013 08:04:09 -0500
In-Reply-To: <1384857809-6573-3-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-0zJe30tnzO+8C0w4qXNJ
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

Hi Jiri,


just two comments:


>  		addrconf_verify(0);
>  		return 0;
> @@ -3609,6 +3617,7 @@ static int inet6_addr_modify(struct inet6_ifaddr *i=
fp, u32 ifa_flags,
>  	u32 flags;
>  	clock_t expires;
>  	unsigned long timeout;
> +	bool was_managetempaddr;
> =20
>  	if (!valid_lft || (prefered_lft > valid_lft))
>  		return -EINVAL;
> @@ -3632,7 +3641,10 @@ static int inet6_addr_modify(struct inet6_ifaddr *=
ifp, u32 ifa_flags,
>  	}
> =20
>  	spin_lock_bh(&ifp->lock);


We should make sure here, not to allow IFA_F_MANAGETEMPADDR, if ifp has
prefixlen!=3D64 or is IFA_F_TEMPORARY itself. Note, that inet6_rtm_newaddr
does check for ifm->ifa_prefixlen !=3D 64, but when modifying an existing
address, the ifm->ifa_prefixlen is not relevant.


> -	ifp->flags =3D (ifp->flags & ~(IFA_F_DEPRECATED | IFA_F_PERMANENT | IFA=
_F_NODAD | IFA_F_HOMEADDRESS)) | ifa_flags;
> +	was_managetempaddr =3D ifp->flags & IFA_F_MANAGETEMPADDR;
> +	ifp->flags &=3D ~(IFA_F_DEPRECATED | IFA_F_PERMANENT | IFA_F_NODAD |
> +			IFA_F_HOMEADDRESS | IFA_F_MANAGETEMPADDR);
> +	ifp->flags |=3D ifa_flags;
>  	ifp->tstamp =3D jiffies;
>  	ifp->valid_lft =3D valid_lft;
>  	ifp->prefered_lft =3D prefered_lft;
> @@ -3643,6 +3655,14 @@ static int inet6_addr_modify(struct inet6_ifaddr *=
ifp, u32 ifa_flags,
> =20
>  	addrconf_prefix_route(&ifp->addr, ifp->prefix_len, ifp->idev->dev,
>  			      expires, flags);
> +
> +	if (was_managetempaddr || ifp->flags & IFA_F_MANAGETEMPADDR) {
> +		if (was_managetempaddr && !(ifp->flags & IFA_F_MANAGETEMPADDR))
> +			valid_lft =3D prefered_lft =3D 0;
> +		manage_tempaddrs(ifp->idev, ifp, valid_lft, prefered_lft,
> +				 false, jiffies);

I think, the parameter "create" of manage_tempaddrs should be set to
"!was_managetempaddr", because we want to force creation of a new
temporary address, if ifp just gets the flag IFA_F_MANAGETEMPADDR
(without having it before).





Thomas

--=-0zJe30tnzO+8C0w4qXNJ
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.15 (GNU/Linux)

iQIcBAABAgAGBQJSle19AAoJEKHCmQ/SsOFd8RYP/1+E4AGtaAukfOyJC/FfWGz3
nipS44uoqIYk3QX++Df3Q/ZiawtgrRdfJd8QIfJGEqjMeLrE5E2NIt5y452aKT5y
6mqF6qhBnvOYtHravzARO9xZ2HZdIIlMAhFepW1znVGQs+yA0W/b5GYYrxpXZSMA
mkmOaQk3Am2DO+jLIycw7xDaxbWopolLcr8hv4/KTgN9siAkl4gpBjwUlt9djbFs
GBVAv8w0M0t5kOvQLYF0m27qmAWNGSAijgtZpf9b4ne1lpDeXiIxR8YTbV0LDxrX
69lOFSPecM5Qq85ZE8n/Vu6xc9jDMJEkOjmatpGURjxBbNFKOD+0wamRRvGAXe/1
4PfYTZjlZPLF9FVOIeQLPJHpO20MBk/COJ14lk4g3XkV8Vp71UE1+T/6JKpuB7Sn
Q60/KzW1VhXZ4DJNG/svDkdZ0KB+Rj8jVFi32YqMc9mK0ZehgW9sB58bh7TvR7mp
t7g1m+XBejinuNHhIyvJmRJsyH2LhfGvqm8R5NxORO4S92VdtQxNE077TFCLpjC1
WyFVqhjR3rOtPp/eUzX9qwcIimZMyOej5Da/260MQWeQUkjtKDs8z8AcBg808R3H
CF+nbP8MevfRAXYkjim3pgA814NWWWpRom4xCqIAK4cGFAAfZbAl8nDipL9Jx19i
dr0PFS0ihonjOOR38jaj
=T/82
-----END PGP SIGNATURE-----

--=-0zJe30tnzO+8C0w4qXNJ--
