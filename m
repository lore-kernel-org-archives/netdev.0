From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: Re: sha512: make it work, undo percpu message schedule
Date: Fri, 13 Jan 2012 12:02:55 +0100
Message-ID: <20120113110255.GD12501@secunet.com>
References: <20120111000040.GA3801@p183.telecom.by>
 <20120111003611.GA12257@gondor.apana.org.au>
 <20120112235514.GA5065@p183.telecom.by>
 <20120113070813.GA20068@gondor.apana.org.au>
 <1326450942.2272.20.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
	Alexey Dobriyan <adobriyan@gmail.com>,
	linux-crypto@vger.kernel.org, netdev@vger.kernel.org,
	ken@codelabs.ch
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:57120 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752772Ab2AMLC5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 13 Jan 2012 06:02:57 -0500
Content-Disposition: inline
In-Reply-To: <1326450942.2272.20.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jan 13, 2012 at 11:35:42AM +0100, Eric Dumazet wrote:
> Le vendredi 13 janvier 2012 =E0 18:08 +1100, Herbert Xu a =E9crit :
> > On Fri, Jan 13, 2012 at 02:55:14AM +0300, Alexey Dobriyan wrote:
> > >
> > > Herbert, I couldn't come up with a single scenario. :-(
> > > But the bug is easy to reproduce.
> >=20
> > OK, does this patch work for you?
> >=20
> > commit 31f4e55c09c1170f8b813c14b1299b70f50db414
> > Author: Herbert Xu <herbert@gondor.apana.org.au>
> > Date:   Fri Jan 13 18:06:50 2012 +1100
> >=20
> >     crypto: sha512 - Fix msg_schedule race
> >    =20
> >     The percpu msg_schedule setup was unsafe as a user in a process
> >     context can be interrupted by a softirq user which would then
> >     scribble over the exact same work area.  This was discovered by
> >     Steffen Klassert.
> >    =20
> >     This patch based on ideas from Eric Dumazet fixes this by using
> >     two independent work areas.
> >    =20
> >     Reported-by: Alexey Dobriyan <adobriyan@gmail.com>
> >     Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>
> >=20
>=20
> I wonder ...
>=20
> With 4096 cpus, do we really want to reserve 5242880 bytes of memory =
for
> this function ?
>=20
> What about following patch instead ?
>=20
> (Trying a dynamic memory allocation, and fallback on a single
> pre-allocated bloc of memory, shared by all cpus, protected by a
> spinlock)

If we want to do dynamic memory allocation, we could place it to the
shash_desc context where we already store the intermediate digest value=
=2E
This is preallocated anyway, so we don't need to do another allocation.
