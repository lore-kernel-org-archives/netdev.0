From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next-2.6] tg3: 64bits stats
Date: Mon, 05 Jul 2010 20:07:10 +0200
Message-ID: <1278353230.2877.601.camel@edumazet-laptop>
References: <1278321242.2877.18.camel@edumazet-laptop>
	 <1278345780.2877.376.camel@edumazet-laptop>
	 <1278351070.2087.70.camel@achroite.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Matt Carlson <mcarlson@broadcom.com>,
	Michael Chan <mchan@broadcom.com>,
	netdev <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ew0-f46.google.com ([209.85.215.46]:41044 "EHLO
	mail-ew0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752043Ab0GESN6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Jul 2010 14:13:58 -0400
Received: by ewy23 with SMTP id 23so1662980ewy.19
        for <netdev@vger.kernel.org>; Mon, 05 Jul 2010 11:13:57 -0700 (PDT)
In-Reply-To: <1278351070.2087.70.camel@achroite.uk.solarflarecom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le lundi 05 juillet 2010 =C3=A0 18:31 +0100, Ben Hutchings a =C3=A9crit=
 :
> On Mon, 2010-07-05 at 18:03 +0200, Eric Dumazet wrote:
> > Le lundi 05 juillet 2010 =C3=A0 11:14 +0200, Eric Dumazet a =C3=A9c=
rit :
> > > After commit be1f3c2c027c (net: Enable 64-bit net device statisti=
cs on
> > > 32-bit architectures), we can now provide 64bit stats, even on 32=
bit
> > > arches.
> > >=20
> > > Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
> > > ---
> >=20
> > Please disregard this patch.
> >=20
> > There is small possibility a reader might read a 64bit value while
> > another writer makes a change to it, changing high 32bit value.
> >=20
> > A change in core network would be needed to make this 100% safe,
> > possibly using a seqlock to protect dev->stats64
>=20
> I really didn't want to add this overhead and complication to readers
> when only some drivers need it.
>=20

Overhead would be minimal, only in get_stats() method and only for
drivers that want to provide 64 bit stats...

Clearly, rx/tx path must not have any overhead.

Right now, even RTNL 64bit stats are not safe.

Should we revert prior patches or try to make progress ?



