From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [RFC] GRO scalability
Date: Sat, 6 Oct 2012 13:14:07 +0800
Message-ID: <20121006051407.GA27390@gondor.apana.org.au>
References: <1348750130.5093.1227.camel@edumazet-glaptop>
 <CAEP_g=-JAYHXM86AYNp7BhDV+eqfkKVgC+SJS1MVdo0K8fRLSQ@mail.gmail.com>
 <1348769294.5093.1566.camel@edumazet-glaptop>
 <1348769990.5093.1584.camel@edumazet-glaptop>
 <CAEP_g=8B7xZPxye0Kuu-EVKpTDt1a3nsJKb61aaYaqOGsYGx8w@mail.gmail.com>
 <1348841041.5093.2477.camel@edumazet-glaptop>
 <CAEP_g=_nSb-ite51PM-E8SY53yOPiZs8N3gDrYNc0L4OU2Ht=A@mail.gmail.com>
 <1349448747.21172.113.camel@edumazet-glaptop>
 <20121006041155.GA27134@gondor.apana.org.au>
 <1349500126.4883.4.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>, Jesse Gross <jesse@nicira.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sting.hengli.com.au ([178.18.18.71]:54643 "EHLO
	fornost.hengli.com.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1750835Ab2JFFON (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 6 Oct 2012 01:14:13 -0400
Content-Disposition: inline
In-Reply-To: <1349500126.4883.4.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Oct 06, 2012 at 07:08:46AM +0200, Eric Dumazet wrote:
> Le samedi 06 octobre 2012 =E0 12:11 +0800, Herbert Xu a =E9crit :
> > On Fri, Oct 05, 2012 at 04:52:27PM +0200, Eric Dumazet wrote:
> > > Current GRO cell is somewhat limited :
> > >=20
> > > - It uses a single list (napi->gro_list) of pending skbs
> > >=20
> > > - This list has a limit of 8 skbs (MAX_GRO_SKBS)
> > >=20
> > > - Workloads with lot of concurrent flows have small GRO hit rate =
but
> > >   pay high overhead (in inet_gro_receive())
> > >=20
> > > - Increasing MAX_GRO_SKBS is not an option, because GRO
> > >   overhead becomes too high.
> >=20
> > Yeah these were all meant to be addressed at some point.
> >=20
> > > - Packets can stay a long time held in GRO cell (there is
> > >   no flush if napi never completes on a stressed cpu)
> >=20
> > This should never happen though.  NAPI runs must always be
> > punctuated just to guarantee one card never hogs a CPU.  Which
> > driver causes these behaviour?
>=20
> I believe its a generic issue, not specific to a driver.
>=20
> napi_gro_flush() is only called from napi_complete()=20
>=20
> Some drivers (marvell/skge.c & realtek/8139cp.c) calls it only becaus=
e
> they 'inline' napi_complete()

So which driver has the potential of never doing napi_gro_flush?

Cheers,
--=20
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
