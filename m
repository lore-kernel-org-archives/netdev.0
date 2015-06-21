From: Sven Eckelmann <sven@narfation.org>
Subject: Re: [PATCH 1/2] batman-adv: Avoid u32 overflow during gateway select
Date: Sun, 21 Jun 2015 20:27:45 +0200
Message-ID: <1534492.Qn5WYoJSum@sven-edge>
References: <1434481584-1275-1-git-send-email-antonio@meshcoding.com> <1434481584-1275-2-git-send-email-antonio@meshcoding.com> <20150621.093713.572451264516042062.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: multipart/signed; boundary="nextPart3043306.pmRPLzhzjv"; micalg="pgp-sha512"; protocol="application/pgp-signature"
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
	ruben@freifunk-nrw.de, ruben@vfn-nrw.de,
	mareklindner@neomailbox.ch, David Miller <davem@davemloft.net>
To: antonio@meshcoding.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from narfation.org ([79.140.41.39]:59230 "EHLO v3-1039.vlinux.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752425AbbFUShM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 21 Jun 2015 14:37:12 -0400
In-Reply-To: <20150621.093713.572451264516042062.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--nextPart3043306.pmRPLzhzjv
Content-Transfer-Encoding: 7Bit
Content-Type: text/plain; charset="us-ascii"

On Sunday 21 June 2015 09:37:13 David Miller wrote:
> From: Antonio Quartulli <antonio@meshcoding.com>
> Date: Tue, 16 Jun 2015 21:06:23 +0200
> 
> > @@ -133,7 +133,7 @@ batadv_gw_get_best_gw_node(struct batadv_priv
> > *bat_priv)> 
> >  	struct batadv_neigh_node *router;
> >  	struct batadv_neigh_ifinfo *router_ifinfo;
> >  	struct batadv_gw_node *gw_node, *curr_gw = NULL;
> > 
> > -	uint32_t max_gw_factor = 0, tmp_gw_factor = 0;
> > +	uint64_t max_gw_factor = 0, tmp_gw_factor = 0;
> > 
> >  	uint32_t gw_divisor;
> 
> Divides are performed using these variables, so if you make
> them 64-bit the build will fail.  You have to use one of the
> routines in include/linux/math64.h in this situation, but
> realize that this operation is now going to be quite expensive.

Just a minor comment: The division is currently "max_gw_factor >> 18" which 
the compiler also outputs as such (shrd + shr on i586). This is the reason why 
it currently also works on architectures without a native 64 bit div.

Kind regards,
	Sven
--nextPart3043306.pmRPLzhzjv
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part.
Content-Transfer-Encoding: 7Bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAABCgAGBQJVhwIkAAoJEF2HCgfBJntG9wUQAMfCAQwvAIaIe/xOQudm9ZE6
tjv3CsAHV7XIU/kpcTsd9+kXgUpUMWlv2QLW8+MnAyem7rAohLA8BTgaJ8reOjBu
OK+e8pv3Zq2CAMwvqviHXS3i6CASaFY53klFlwewSxKvcGygfhXDbdMyV2GHYIef
v6PD6x0T0rMCSz7RY5aeN17QiNMJLOW2lkzS7hxEw5ZZZbr6UvEBIMcrclGOhznS
9Ww9phZKkr09qPMcAasSjLSIs+ZZK/J425OXQ4nKMG9UOFpM5nFRyJVy98c9PAiG
1ELzwXgV+KFPftL3KmbOV4tlZDQcw9X6DfC/qPVewzpiTbRl24ufOIGbxa9POVEQ
meMXBIxbDgYTqeJHbH8E2RAIY8nSMAbgqj6Vx6lkhZI66SLh7fwWmlZlh69d6Bft
i/4doemeW6SLovNgoLiT+Zspg1qpXXryNkCi4vjoUfZOzO+2z0qYi7V+KbFmh7NT
WRiJ/6OjbbFNi+V4FVR11LIslnYG8dd+C0UYmND0KYQkv0tuMd7TqSQ9QX6fKUrC
UAZI5hBg6cL7KfG7xz9Nt8nH305C3KQb78O+hoIQWSK25vKJCP3gmZ5SvcSOFJtq
jTjZ8aZILYL7NyAE0SW6wACO4q4rM8YpPF098MF1SQlJXHE2U2PEA3/Ox3lVFz7f
VG+ufCog2ydvbM141vG2
=S3+s
-----END PGP SIGNATURE-----

--nextPart3043306.pmRPLzhzjv--
