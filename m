From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: NULL pointer dereference panic in stable (2.6.33.2), amd64
Date: Mon, 12 Apr 2010 01:11:23 +0200
Message-ID: <1271027483.2078.158.camel@edumazet-laptop>
References: <201004112338.47019.nuclearcat@nuclearcat.com>
	 <1271025353.2078.155.camel@edumazet-laptop>
	 <201004120204.11405.nuclearcat@nuclearcat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, Krishna Kumar <krkumar2@in.ibm.com>,
	David Miller <davem@davemloft.net>
To: Denys Fedorysychenko <nuclearcat@nuclearcat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f219.google.com ([209.85.218.219]:54236 "EHLO
	mail-bw0-f219.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752967Ab0DKXL2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 11 Apr 2010 19:11:28 -0400
Received: by bwz19 with SMTP id 19so65414bwz.21
        for <netdev@vger.kernel.org>; Sun, 11 Apr 2010 16:11:27 -0700 (PDT)
In-Reply-To: <201004120204.11405.nuclearcat@nuclearcat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le lundi 12 avril 2010 =C3=A0 02:04 +0300, Denys Fedorysychenko a =C3=A9=
crit :
> > It is IMHO not safe, because route for this socket might have just
> > changed and we are transmitting an old packet (queued some milli se=
conds
> > before, when route was different).
> >=20
> > We then memorize a queue_index that might be too big for the new de=
vice
> > of new selected route.
> >=20
> > Next packet we want to transmit will take the cached value of
> > queue_index, correct for old device, maybe not correct for new devi=
ce.
> Yes, it is possible, i have there RIP with 1k+ routes, changing non-s=
top.
>=20
> >=20
> > You could try to revert commit a4ee3ce3293dc931fab19beb472a8bde1295=
aebe
> >=20
> > commit a4ee3ce3293dc931fab19beb472a8bde1295aebe
> I will try to revert it now. But to trigger bug probably i need 1-2 d=
ays.

I can try to reproduce bug here, with a multiqueue device, a non
multiqueue device, and changing routes while transmitting bulk of
packets, and of course some trafic shaping to slow down xmits.

Could you send :

ifconfig -a
lspci

Thanks


