From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH] macvlan: lockless tx path
Date: Wed, 10 Nov 2010 21:53:37 +0000
Message-ID: <1289426017.2249.56.camel@achroite.uk.solarflarecom.com>
References: <1289403709.2860.216.camel@edumazet-laptop>
	 <4CDAD8C8.20807@candelatech.com>
	 <1289411027.2860.248.camel@edumazet-laptop>
	 <4CDADC17.6070506@candelatech.com>
	 <1289413120.2469.12.camel@edumazet-laptop>
	 <4CDAE713.7020309@candelatech.com>
	 <1289421187.2469.127.camel@edumazet-laptop>
	 <1289423056.2249.7.camel@achroite.uk.solarflarecom.com>
	 <1289423555.17691.8.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Ben Greear <greearb@candelatech.com>,
	David Miller <davem@davemloft.net>,
	Patrick McHardy <kaber@trash.net>,
	netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:7966 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757166Ab0KJVxm convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Nov 2010 16:53:42 -0500
In-Reply-To: <1289423555.17691.8.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2010-11-10 at 22:12 +0100, Eric Dumazet wrote:
> Le mercredi 10 novembre 2010 =C3=A0 21:04 +0000, Ben Hutchings a =C3=A9=
crit :
>=20
> > Drivers should calculate differences and accumulate them in a 64-bi=
t
> > counter.  (A lot of hardware has read-to-clear counters anyway, in =
which
> > case the driver *has* to accumulate the values it reads.)
>=20
> You are mistaken. These are _hardware_ counters. If they were softwar=
e,
> of course they would be 32 or 64 bit.

Of course I understood that.

> And doing the thing you describe in software is racy.
> I tried to remove many races, not to add new ones.

If you do it in ndo_get_stats{,64} and don't use your own lock, yes.

> Yes, some drivers read one hardware counter using two instructions, a=
nd
> this is racy.

Most hardware which supports MMIO to multi-word counters has some kind
of latching scheme where you can read the words/registers in order and
get consistent values (within a single counter; consistency between
counters is another matter).  Obviously you have to use a lock to
serialise stats updates in this case - whether or not you maintain wide=
r
software counters.

Oh, another problem with using register values directly is that
statistics are likely to be reset whenever the device is reconfigured i=
n
the way that requires a hardware reset.

Ben.

--=20
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

