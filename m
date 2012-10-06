From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [RFC] GRO scalability
Date: Sat, 06 Oct 2012 07:08:46 +0200
Message-ID: <1349500126.4883.4.camel@edumazet-laptop>
References: <1348750130.5093.1227.camel@edumazet-glaptop>
	 <CAEP_g=-JAYHXM86AYNp7BhDV+eqfkKVgC+SJS1MVdo0K8fRLSQ@mail.gmail.com>
	 <1348769294.5093.1566.camel@edumazet-glaptop>
	 <1348769990.5093.1584.camel@edumazet-glaptop>
	 <CAEP_g=8B7xZPxye0Kuu-EVKpTDt1a3nsJKb61aaYaqOGsYGx8w@mail.gmail.com>
	 <1348841041.5093.2477.camel@edumazet-glaptop>
	 <CAEP_g=_nSb-ite51PM-E8SY53yOPiZs8N3gDrYNc0L4OU2Ht=A@mail.gmail.com>
	 <1349448747.21172.113.camel@edumazet-glaptop>
	 <20121006041155.GA27134@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>, Jesse Gross <jesse@nicira.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f44.google.com ([74.125.82.44]:52158 "EHLO
	mail-wg0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751170Ab2JFFJ7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 6 Oct 2012 01:09:59 -0400
Received: by mail-wg0-f44.google.com with SMTP id dr13so2071132wgb.1
        for <netdev@vger.kernel.org>; Fri, 05 Oct 2012 22:09:58 -0700 (PDT)
In-Reply-To: <20121006041155.GA27134@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le samedi 06 octobre 2012 =C3=A0 12:11 +0800, Herbert Xu a =C3=A9crit :
> On Fri, Oct 05, 2012 at 04:52:27PM +0200, Eric Dumazet wrote:
> > Current GRO cell is somewhat limited :
> >=20
> > - It uses a single list (napi->gro_list) of pending skbs
> >=20
> > - This list has a limit of 8 skbs (MAX_GRO_SKBS)
> >=20
> > - Workloads with lot of concurrent flows have small GRO hit rate bu=
t
> >   pay high overhead (in inet_gro_receive())
> >=20
> > - Increasing MAX_GRO_SKBS is not an option, because GRO
> >   overhead becomes too high.
>=20
> Yeah these were all meant to be addressed at some point.
>=20
> > - Packets can stay a long time held in GRO cell (there is
> >   no flush if napi never completes on a stressed cpu)
>=20
> This should never happen though.  NAPI runs must always be
> punctuated just to guarantee one card never hogs a CPU.  Which
> driver causes these behaviour?

I believe its a generic issue, not specific to a driver.

napi_gro_flush() is only called from napi_complete()=20

Some drivers (marvell/skge.c & realtek/8139cp.c) calls it only because
they 'inline' napi_complete()
