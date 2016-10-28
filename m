From: Sven Eckelmann <sven@narfation.org>
Subject: Re: [PATCH 17/17] batman-adv: Avoid precedence issues in macros
Date: Fri, 28 Oct 2016 23:27:31 +0200
Message-ID: <4261316.fWqmHPy2zE@sven-edge>
References: <20161027190150.7880-1-sw@simonwunderlich.de> <20161027190150.7880-18-sw@simonwunderlich.de> <1477689186.23018.1.camel@perches.com>
Mime-Version: 1.0
Content-Type: multipart/signed; boundary="nextPart1882856.C4O4c5mLdh"; micalg="pgp-sha512"; protocol="application/pgp-signature"
Cc: Simon Wunderlich <sw@simonwunderlich.de>, davem@davemloft.net,
        netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
        Antonio Quartulli <a@unstable.cc>
To: Joe Perches <joe@perches.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from narfation.org ([79.140.41.39]:41539 "EHLO v3-1039.vlinux.de"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S941716AbcJ1V1l (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 28 Oct 2016 17:27:41 -0400
In-Reply-To: <1477689186.23018.1.camel@perches.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--nextPart1882856.C4O4c5mLdh
Content-Transfer-Encoding: 7Bit
Content-Type: text/plain; charset="us-ascii"

On Freitag, 28. Oktober 2016 14:13:06 CEST Joe Perches wrote:
> On Thu, 2016-10-27 at 21:01 +0200, Simon Wunderlich wrote:
> > From: Sven Eckelmann <sven@narfation.org>
> > 
> > It must be avoided that arguments to a macro are evaluated ungrouped (which
> > enforces normal operator precendence). Otherwise the result of the macro
> > is not well defined.
> 
> Curiosity:
> 
> in net/batman-adv/tp_meter.c
[...]
> 	orig_node = batadv_orig_hash_find(bat_priv, tp_vars->other_end);
> 	if (unlikely(!orig_node)) {
> 		err = BATADV_TP_REASON_DST_UNREACHABLE;
> 		tp_vars->reason = err;
> 		goto out;
> 	}
> 
> 	primary_if = batadv_primary_if_get_selected(bat_priv);
> 	if (unlikely(!primary_if)) {
> 		err = BATADV_TP_REASON_DST_UNREACHABLE;
> 		goto out;
> 	}
> 
> err is not used in the out block
> 
> Is the last if block supposed to set tp_vars->reason to err?

This seems to be unrelated to this patch.

But yes, looks to me like it is missing. Do you want to propose a patch or
should I do? Just make sure you Cc Antonio Quartulli <a@unstable.cc> (and of
course b.a.t.m.a.n@lists.open-mesh.org). He is the original author of
33a3bb4a3345 ("batman-adv: throughput meter implementation").

Kind regards,
	Sven
--nextPart1882856.C4O4c5mLdh
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part.
Content-Transfer-Encoding: 7Bit

-----BEGIN PGP SIGNATURE-----

iQIcBAABCgAGBQJYE8LDAAoJEF2HCgfBJntGfygP/RVNHB/cz3ckz8xyJhVzPDr+
CpvX5NM1NbrhP68xvnxIvo9gpnTuZCdelI1dGwqZ59rcMAVLfVAM7OC7XvrxVOrJ
qeqsAzJWbG5aRWRDGU+oQwC1x3ISzTnWduDckEg9NiVvNWD9GZJQv+JDUQJ9N0mz
mSjN02yVHc3FFtVIxOJ8BA34r1n+7zpzS23yQFg5MNuKavCtsxj1Zw2GRpe2TKK5
VlwCRxADJZp+bB2+2McNKNPwsj+nJyay4jtqjWzJLazwd/rVfO5WHw9iPJmWF7rM
nEiNZQjt7hIzCLUusCsXx84W3qs9F3dg/N5GNQtHRoaZCX3b1JSfskLOen/y/4vk
7IE6osFuhbH4y6QzirYovyXehvHTDFNP0k81AqXotxyVqwyQWMHgMBST2xRS5xhl
oGaLrmuom9RBx1bM9DLhkmtr25AZ8k/wf3v6qOZ04Dc8YApNoxK+NAgZMOFE/mOR
r1UOXbnDazo7IN9XPotDaDOpDvB4pLYcWXwez7qjr1z2OVcnh3GyDyMimDW0hrOB
+OPkKrwcV8XtCqtNebz5r7NBs24v1XqL28dZr/kdpEP657R5/1J/oqZgoyxGSU00
2Z3Lq30f2a27EwiNyxVhn2Df427Yz6ZVkfvdB7AJ4dOPl0lmax03XAU4mk6NbmSK
OrFDyR74L3HBMSEAB0vA
=yHW6
-----END PGP SIGNATURE-----

--nextPart1882856.C4O4c5mLdh--
