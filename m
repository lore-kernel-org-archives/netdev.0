From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH net-next-2.6 1/3] be2net: fix netdev_stats_update
Date: Mon, 27 Jun 2011 11:43:57 -0700
Message-ID: <20110627114357.3592fcf1@nehalam.ftrdhcpuser.net>
References: <4da4117c-a24a-4512-9b79-fbed126e03bc@exht1.ad.emulex.com>
	<20110627094337.5108b5f6@nehalam.ftrdhcpuser.net>
	<1309195241.2532.79.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Sathya Perla <sathya.perla@emulex.com>, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:55223 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753512Ab1F0SoB convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 27 Jun 2011 14:44:01 -0400
In-Reply-To: <1309195241.2532.79.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 27 Jun 2011 19:20:41 +0200
Eric Dumazet <eric.dumazet@gmail.com> wrote:

> Le lundi 27 juin 2011 =E0 09:43 -0700, Stephen Hemminger a =E9crit :
> > On Mon, 27 Jun 2011 12:10:48 +0530
> > Sathya Perla <sathya.perla@emulex.com> wrote:
> >=20
> > > Problem initially reproted and fixed by Eric Dumazet <eric.dumaze=
t@gmail.com>
> > >=20
> > > netdev_stats_update() resets netdev->stats and then accumulates s=
tats from
> > > various rings. This is wrong as stats readers can sometimes catch=
 zero values.
> > > Use temporary variables instead for accumulating per-ring values.
> > >=20
> > > Signed-off-by: Sathya Perla <sathya.perla@emulex.com>
> >=20
> > Should also use u64_stats_sync to ensure correct rollover or 32 bit=
 SMP
> > platform.
>=20
> These are "unsigned long" fields, you dont need u64_stats_sync.

The source fields (in be.h) are u64, but since destination is unsigned =
long
that works.
