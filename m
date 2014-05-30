From: "ezequiel.garcia@free-electrons.com"
	<ezequiel.garcia@free-electrons.com>
Subject: Re: [PATCH v1 4/6] net: fec: Increase buffer descriptor entry number
Date: Fri, 30 May 2014 11:01:37 -0300
Message-ID: <20140530140137.GC783@arch.cereza>
References: <1401415552-2263-1-git-send-email-b38611@freescale.com>
 <1401415552-2263-5-git-send-email-b38611@freescale.com>
 <063D6719AE5E284EB5DD2968C1650D6D1725053E@AcuExch.aculab.com>
 <bf938381e86b4ef5b4e3cbec8733fd2e@BLUPR03MB373.namprd03.prod.outlook.com>
 <1401455586.3645.96.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "fugang.duan@freescale.com" <fugang.duan@freescale.com>,
	David Laight <David.Laight@ACULAB.COM>,
	"Frank.Li@freescale.com" <Frank.Li@freescale.com>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"shawn.guo@linaro.org" <shawn.guo@linaro.org>,
	"bhutchings@solarflare.com" <bhutchings@solarflare.com>,
	"stephen@networkplumber.org" <stephen@networkplumber.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from top.free-electrons.com ([176.31.233.9]:57621 "EHLO
	mail.free-electrons.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S933250AbaE3OFc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 May 2014 10:05:32 -0400
Content-Disposition: inline
In-Reply-To: <1401455586.3645.96.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello Eric,

On 30 May 06:13 AM, Eric Dumazet wrote:
> On Fri, 2014-05-30 at 09:42 +0000, fugang.duan@freescale.com wrote:
> > From: David Laight <David.Laight@ACULAB.COM> Data: Friday, May 30, =
2014 5:11 PM
> > >
> > >Does the driver support BQL (or similar) in order to limit the amo=
unt of
> > >queued tx traffic?
> > >Otherwise you've significantly increased the latency for connectio=
ns other
> > >than one doing bulk tx.
> > >
> > >	David
> > >
> > The driver still don't support BQL.
> > I will add the feature to support FEC. Thanks for your advise.
>=20
> Note that a full size TSO packet (44 or 45 MSS) requires about 88 or =
90
> descriptors.
>=20

What's the rationale behing those numbers?

=46ollowing the Solarflare commit you pointed me a while ago, I've set
gso_max_segs to limit the number of descriptors in the mvneta and
mv643xx_eth drivers.

My understanding reading the sfc commit 7e6d06f0de3f7 is that the
maximum number of required descriptors would be around ~250:

/* Header and payload descriptor for each output segment, plus
 * one for every input fragment boundary within a segment
 */
unsigned int max_descs =3D EFX_TSO_MAX_SEGS * 2 + MAX_SKB_FRAGS;

Maybe I've misunderstood something?

PS: I was also about to add BQL support to the drivers...
--=20
Ezequiel Garc=EDa, Free Electrons
Embedded Linux, Kernel and Android Engineering
http://free-electrons.com
