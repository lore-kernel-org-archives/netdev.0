From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: bonding vs GSO vs checksumming.
Date: Tue, 28 Sep 2010 12:21:00 +0900
Message-ID: <20100928032100.GA24983@gondor.apana.org.au>
References: <AANLkTim2FF2n9JXfpdZmmnV5ZJ1ptC7se_JiU_z91okt@mail.gmail.com> <20100928024907.GA24948@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Linux NetDev <netdev@vger.kernel.org>
To: Maciej =?utf-8?Q?=C5=BBenczykowski?= <zenczykowski@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from helcar.apana.org.au ([209.40.204.226]:38848 "EHLO
	fornost.hengli.com.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758036Ab0I1DVD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 27 Sep 2010 23:21:03 -0400
Content-Disposition: inline
In-Reply-To: <20100928024907.GA24948@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Sep 28, 2010 at 11:49:07AM +0900, Herbert Xu wrote:
> On Thu, Sep 23, 2010 at 05:56:43PM -0700, Maciej =C5=BBenczykowski wr=
ote:
> > I'm seeing the following:
> >=20
> > bonding: caps=3D(0x1113a3, 0x1113ab) len=3D18192 data_len=3D18120 i=
p_summed=3D0
> >=20
> > on a 2.6.34.5 based kernel originating from v6 tcp transmit (mtu 12=
80)
> > on a bonded device of tg3 (presumably with TSO6) and forcedeth
> > (presumably without TSO6).
> >=20
> > I can't quite figure out what this truly means...
>=20
> Did it come with a kernel backtrace?

Actually your particular problem should be fixed by

commit 6afff0caa721211e8c04bdc7627ee3bff95bcb95
Author: John Fastabend <john.r.fastabend@intel.com>
Date:   Wed Jun 16 14:18:12 2010 +0000

    net: consolidate netif_needs_gso() checks

which went in after 2.6.34.

However, the fact that your feature bits show that bonding is
declaring TSO6 support without IPv6 checksum support also means
that the bonding feature computation is broken.

Thanks,
--=20
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
