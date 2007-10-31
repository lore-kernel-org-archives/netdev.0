From: Peter Zijlstra <a.p.zijlstra@chello.nl>
Subject: Re: [PATCH 06/33] mm: allow PF_MEMALLOC from softirq context
Date: Wed, 31 Oct 2007 11:42:39 +0100
Message-ID: <1193827359.27652.129.camel@twins>
References: <20071030160401.296770000@chello.nl>
	 <20071030160911.540148000@chello.nl>
	 <200710311451.56747.nickpiggin@yahoo.com.au>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-r7nMOlku9KeVdHIURXUD"
Cc: Linus Torvalds <torvalds@linux-foundation.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	linux-kernel@vger.kernel.org, linux-mm@kvack.org,
	netdev@vger.kernel.org, trond.myklebust@fys.uio.no
To: Nick Piggin <nickpiggin@yahoo.com.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from viefep18-int.chello.at ([213.46.255.22]:64286 "EHLO
	viefep15-int.chello.at" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1755547AbXJaKms (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 31 Oct 2007 06:42:48 -0400
In-Reply-To: <200710311451.56747.nickpiggin@yahoo.com.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-r7nMOlku9KeVdHIURXUD
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Wed, 2007-10-31 at 14:51 +1100, Nick Piggin wrote:
> On Wednesday 31 October 2007 03:04, Peter Zijlstra wrote:
> > Allow PF_MEMALLOC to be set in softirq context. When running softirqs f=
rom
> > a borrowed context save current->flags, ksoftirqd will have its own
> > task_struct.
>=20
>=20
> What's this for? Why would ksoftirqd pick up PF_MEMALLOC? (I guess
> that some networking thing must be picking it up in a subsequent patch,
> but I'm too lazy to look!)... Again, can you have more of a rationale in
> your patch headers, or ref the patch that uses it... thanks

Right, I knew I was forgetting something in these changelogs.

The network stack does quite a bit of packet processing from softirq
context. Once you start swapping over network, some of the packets want
to be processed under PF_MEMALLOC.

See patch 23/33.

--=-r7nMOlku9KeVdHIURXUD
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.6 (GNU/Linux)

iD8DBQBHKFwfXA2jU0ANEf4RAkgXAJ98pKdDwE2bTcSNPFtXgN9xp6eTXwCdFhg/
ATCE0SfG+kL0D0HkFDOIv3A=
=xQNH
-----END PGP SIGNATURE-----

--=-r7nMOlku9KeVdHIURXUD--

