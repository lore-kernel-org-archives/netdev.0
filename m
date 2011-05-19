From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 4/4] rps: Inspect GRE encapsulated packets to get flow
 hash
Date: Thu, 19 May 2011 22:17:47 +0200
Message-ID: <1305836267.3156.15.camel@edumazet-laptop>
References: <alpine.DEB.2.00.1105190827420.12804@pokey.mtv.corp.google.com>
	 <1305821795.3028.82.camel@edumazet-laptop>
	 <BANLkTinZOEz7Bhc+UgcWkrGb-rtCJ-kFvg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Tom Herbert <therbert@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:57030 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S934077Ab1ESURv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 May 2011 16:17:51 -0400
Received: by wya21 with SMTP id 21so2259726wya.19
        for <netdev@vger.kernel.org>; Thu, 19 May 2011 13:17:50 -0700 (PDT)
In-Reply-To: <BANLkTinZOEz7Bhc+UgcWkrGb-rtCJ-kFvg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le jeudi 19 mai 2011 =C3=A0 12:56 -0700, Tom Herbert a =C3=A9crit :
> Eric,
>=20
> Thanks for comments.
>=20
> > For sure it helps if this machine is the final host for these packe=
ts.
> >
> I would hope it helps routers too, assuming RPS already helps non
> encapsulated traffic in a router.

If conntracking is active, RPS probably helps. (Not tested yet here)

>=20
> > If I am a firewall or router [and not looking into GRE packets], ma=
ybe I
> > dont want to spread all packets received on a tunnel to several cpu=
s and
> > reorder them when forwarded.
> >
> Do know a specific use case where this patch would be a bad thing?  I
> don't believe there's any special ooo constraints on the packets in a
> tunnel, flow ordering should still be maintained.
>=20

I was referring of reordering packets coming and outgoing, this could
defeat an AQM (the source carefully ordered packets with SFQ or other
qdisc, and we send them in different order).

You and David thought I was speaking of possible OOO for packets of a
given flow. I'm pretty confident you did this right :)

> > 3) table could contains 'pointers' to decoding function, that would
> > recompute a new rxhash function.
> >
> This could be done as a function in the protocol switch table, so tha=
t
> all the protocol specific code could be moved out of dev.c.  I though=
t
> about that several times but haven't convinced myself it's worth it;
> even with the code to handle tunneling the get_hash function is still
> pretty elegant (I believe ipip support is just two more lines by the
> way).

Yes, anyway this can be done later.

I find a bit annoying that such changes are pushed right before merge
window when we have litle time, thats all.

Thanks


