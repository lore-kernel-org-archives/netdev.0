From: Peter Zijlstra <a.p.zijlstra@chello.nl>
Subject: Re: [PATCH 00/33] Swap over NFS -v14
Date: Wed, 31 Oct 2007 11:56:46 +0100
Message-ID: <1193828206.27652.145.camel@twins>
References: <20071030160401.296770000@chello.nl>
	 <200710311426.33223.nickpiggin@yahoo.com.au>
	 <20071030.213753.126064697.davem@davemloft.net>
	 <20071031085041.GA4362@infradead.org>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-cUHl4ABf0oLSQQRRgXos"
Cc: David Miller <davem@davemloft.net>, nickpiggin@yahoo.com.au,
	torvalds@linux-foundation.org, akpm@linux-foundation.org,
	linux-kernel@vger.kernel.org, linux-mm@kvack.org,
	netdev@vger.kernel.org, trond.myklebust@fys.uio.no
To: Christoph Hellwig <hch@infradead.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from viefep18-int.chello.at ([213.46.255.22]:29803 "EHLO
	viefep33-int.chello.at" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1757878AbXJaK46 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 31 Oct 2007 06:56:58 -0400
In-Reply-To: <20071031085041.GA4362@infradead.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-cUHl4ABf0oLSQQRRgXos
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Wed, 2007-10-31 at 08:50 +0000, Christoph Hellwig wrote:
> On Tue, Oct 30, 2007 at 09:37:53PM -0700, David Miller wrote:
> > Don't be misled.  Swapping over NFS is just a scarecrow for the
> > seemingly real impetus behind these changes which is network storage
> > stuff like iSCSI.
>=20
> So can we please do swap over network storage only first?  All these
> VM bits look conceptually sane to me, while the changes to the swap
> code to support nfs are real crackpipe material.

Yeah, I know how you stand on that. I just wanted to post all this
before going off into the woods reworking it all.

> Then again doing
> that part properly by adding address_space methods for swap I/O without
> the abuse might be a really good idea, especially as the way we
> do swapfiles on block-based filesystems is an horrible hack already.

Is planned. What do you think of the proposed a_ops extension to
accomplish this? That is,

->swapfile() - is this address space willing to back swap
->swapout() - write out a page
->swapin() - read in a page

> So please get the VM bits for swap over network blockdevices in first,

Trouble with that part is that we don't have any sane network block
devices atm, NBD is utter crap, and iSCSI is too complex to be called
sane.

Maybe Evgeniy's Distributed storage thingy would work, will have a look
at that.

> and then we can look into a complete revamp of the swapfile support
> that cleans up the current mess and adds support for nfs insted of
> making the mess even worse.

Sure, concrete suggestion are always welcome. Just being told something
is utter crap only goes so far.

--=-cUHl4ABf0oLSQQRRgXos
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.6 (GNU/Linux)

iD8DBQBHKF9uXA2jU0ANEf4RAieaAKCGdTzP/wHrCLDUDz9z475A0L5bVQCbBcEK
4yhY/VPt+xfs+DU4yvLpMS8=
=9lsn
-----END PGP SIGNATURE-----

--=-cUHl4ABf0oLSQQRRgXos--

