From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next-2.6] net: force a fresh timestamp for ingress
 packets
Date: Thu, 16 Dec 2010 22:30:39 +0100
Message-ID: <1292535039.2655.13.camel@edumazet-laptop>
References: <1292428252.3427.342.camel@edumazet-laptop>
	 <20101216211744.GA2191@del.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	Changli Gao <xiaosuo@gmail.com>,
	netdev <netdev@vger.kernel.org>,
	Patrick McHardy <kaber@trash.net>
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:56980 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757019Ab0LPVao (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Dec 2010 16:30:44 -0500
Received: by wwa36 with SMTP id 36so3613wwa.1
        for <netdev@vger.kernel.org>; Thu, 16 Dec 2010 13:30:43 -0800 (PST)
In-Reply-To: <20101216211744.GA2191@del.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le jeudi 16 d=C3=A9cembre 2010 =C3=A0 22:17 +0100, Jarek Poplawski a =C3=
=A9crit :
> On Wed, Dec 15, 2010 at 04:50:52PM +0100, Eric Dumazet wrote:
> > In commit 8caf153974f2 (net: sch_netem: Fix an inconsistency in ing=
ress
> > netem timestamps.), Jarek added a logic to refresh timestamps of
> > ingressed packets going through netem.
> >=20
> > I believe we should generalize this, forcing a refresh of timestamp=
s in
> > dev_queue_xmit_nit() for all ingress packets, whatever qdisc/class =
they
> > used before being delivered.
> >=20
> > This way, we can have a good idea when packets are delivered to our
> > stack (tcpdump -i ifb0), while a tcpdump on original device gives
> > timestamps right before ingressing.
>=20
> I don't think we should do it. IMHO netem on ingress is a special cas=
e,
> obviously for testing, and otherwise the real (first) timestamp might
> be valuable for some users.

Well, I find difficult to check sfq is actually correctly working
because timestamps are mixed.

After this patch, I found the SFQ allot error for example.

I dont know, I feel adding a sysctl like netdev_tstamp_prequeue is not
worth it...


