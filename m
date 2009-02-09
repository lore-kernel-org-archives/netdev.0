From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: commit 64ff3b938ec6782e6585a83d5459b98b0c3f6eb8 breaks rlogin
Date: Mon, 9 Feb 2009 18:33:39 +1100
Message-ID: <20090209073339.GA4796@gondor.apana.org.au>
References: <20090206054541.GA4954@gondor.apana.org.au> <b6a2187b0902060335h646e8d86pf00773035f577665@mail.gmail.com> <20090209055848.GA3889@gondor.apana.org.au> <20090208.220357.261414983.davem@davemloft.net> <20090209061151.GA3982@gondor.apana.org.au> <Pine.LNX.4.64.0902090853360.20576@wrl-59.cs.helsinki.fi> <20090209072806.GB4380@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, jeff.chua.linux@gmail.com,
	rjw@sisk.pl, torvalds@linux-foundation.org,
	LKML <linux-kernel@vger.kernel.org>,
	Netdev <netdev@vger.kernel.org>
To: Ilpo =?iso-8859-1?Q?J=E4rvinen?= <ilpo.jarvinen@helsinki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:60288 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753809AbZBIHeB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Feb 2009 02:34:01 -0500
Content-Disposition: inline
In-Reply-To: <20090209072806.GB4380@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Feb 09, 2009 at 06:28:06PM +1100, Herbert Xu wrote:
> On Mon, Feb 09, 2009 at 09:13:00AM +0200, Ilpo J=E4rvinen wrote:
> >=20
> > Hmm, what happens if a opposite dir ACK gets sent (it's zero sized =
seqno
> > range will be above urgent sequence when urg is not yet acknowledge=
d)? So
> > we'll take the later branch after your change and send bogus 0xffff=
 urg?
> > I think you're change might have actually broken bidir tcp complete=
ly (and
> > probably window probing as well under some conditions). Congraz, tw=
o flies
> > with a single stroke :-). You would have needed an additional check=
 that
> > the tcb->seq is below urg...
> >=20
> > ...Below is a patch but Jeff might need to revert the revert first =
if
> > he tests with the latest Linus' tree.
>=20
> Good point! That would definitely explain this.

Actually, I don't see how we can have tcp_urg_mode being true
when his strace shows no OOB data at all (it only did write
and writev).

So I'm not sure if this bug is the one causing this.

Cheers,
--=20
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
