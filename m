From: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Subject: Re: BUG: scheduling while atomic: ifconfig/0x00000002/4170
Date: Thu, 06 Sep 2007 14:46:22 +0200
Message-ID: <1189082782.28781.73.camel@johannes.berg>
References: <20070902184439.GA14306@paradigm.rfc822.org>
	 <6bffcb0e0709021659o3856cd06gabc054c949a84397@mail.gmail.com>
	 <alpine.LFD.0.999.0709060923340.26804@enigma.security.iitk.ac.in>
	 <20070906082301.GB21929@gondor.apana.org.au>
	 <1189080575.28781.65.camel@johannes.berg>
	 <alpine.LFD.0.999.0709061818270.3781@enigma.security.iitk.ac.in>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-OEAwj4NgJ4JvB5JCyVGC"
Cc: Herbert Xu <herbert-lOAM2aK0SrRLBo1qDEOMRrpzq4S04n8Q@public.gmane.org>,
	Florian Lohoff <flo-BCn6idZOOBwdnm+yROfE0A@public.gmane.org>,
	Linux Kernel Mailing List <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Michal Piotrowski <michal.k.k.piotrowski-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	ipw3945-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org, yi.zhu-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org,
	Michael Wu <flamingice-R9e9/4HEdknk1uMJSBkQmQ@public.gmane.org>
To: Satyam Sharma <satyam-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <alpine.LFD.0.999.0709061818270.3781-cF9xTIDbLT5E1qDFBaZ7QYsk13R+tSIrn9A1Ff6Mc9Q@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org


--=-OEAwj4NgJ4JvB5JCyVGC
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Thu, 2007-09-06 at 18:22 +0530, Satyam Sharma wrote:

> Unless I missed something obvious (let me know if that's the case! :-)
> an RCU-protected list would suffer the same fate. list_for_each_xxx_rcu()
> must be under rcu_read_lock() which =3D=3D preempt_disable() ...

Right. But I'm thinking that since all list manipulations are done under
RTNL we only need to protect against removing things from the list while
the RX or TX path is using it, so only it would have to use it under
rcu_read_lock() [which it already takes due to key management] so we
could get rid of that sub_if_lock completely. There is one issue with
this I know about and that is the management skb queue but I'll have to
take a closer look.

johannes

--=-OEAwj4NgJ4JvB5JCyVGC
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Comment: Johannes Berg (powerbook)

iD8DBQBG3/ae/ETPhpq3jKURAlr2AJ0ce7Jw3F7kk9YTsyTeNb0xzYh5ngCfZpwT
6eWDYesw2yNcEEa+vjVa46E=
=BPmk
-----END PGP SIGNATURE-----

--=-OEAwj4NgJ4JvB5JCyVGC--
