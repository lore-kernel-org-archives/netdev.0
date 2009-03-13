From: David Miller <davem@davemloft.net>
Subject: Re: [RFC] tcp: allow timestamps even if SYN packet has tsval=0
Date: Fri, 13 Mar 2009 14:25:07 -0700 (PDT)
Message-ID: <20090313.142507.47563051.davem@davemloft.net>
References: <49B7ABF2.5040803@cosmosbay.com>
	<20090311.064710.255854254.davem@davemloft.net>
	<Pine.LNX.4.64.0903120858550.4697@wrl-59.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: dada1@cosmosbay.com, netdev@vger.kernel.org
To: ilpo.jarvinen@helsinki.fi
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:36864
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753093AbZCMVZV convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 13 Mar 2009 17:25:21 -0400
In-Reply-To: <Pine.LNX.4.64.0903120858550.4697@wrl-59.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: "Ilpo J=E4rvinen" <ilpo.jarvinen@helsinki.fi>
Date: Thu, 12 Mar 2009 09:26:20 +0200 (EET)

> On Wed, 11 Mar 2009, David Miller wrote:
>=20
> > From: Eric Dumazet <dada1@cosmosbay.com>
> > Date: Wed, 11 Mar 2009 13:17:54 +0100
> >=20
> > > So apparently WindowsXP sends a NULL tsval in SYN packet, then
> > > subsequent packets get a real value (60498) in this case.
> > >=20
> > > This seems to work on other OS as well, so is the following patch
> > > considered evil ?  Do we have security concerns or only risking
> > > windows client to have slightly wrong rtt estimation at the begin=
ing
> > > of the tcp session ?
> >=20
> > I think we'll have to accept this.
> >=20
> > I don't see other systems blocking initial ts_ecn values of
> > zero like we do.
>=20
> What about the fact that PAWS could bite us leaving us a hung connect=
ion=20
> if timestamp changes too much when we get the first ACK? Though I dou=
bt=20
> you can get windows to run long enough for this to become a problem i=
f=20
> they always start from zero... ;-)

I really don't think it's a real issue, and Windows XP should be happy
we're willing to try timestamps at all with it :-)
