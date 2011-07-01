From: David Lamparter <equinox@diac24.net>
Subject: bridge vs. bonding/pause frames (was: Forward EAPOL...)
Date: Fri, 1 Jul 2011 17:16:26 +0200
Message-ID: <20110701151626.GC2613105@jupiter.n2.diac24.net>
References: <BANLkTi=goXU4SpP6dxX9C+YeLcVMEkcKHw@mail.gmail.com>
 <20110628202200.GB2121496@jupiter.n2.diac24.net>
 <BANLkTim1owW7iMS3hgKhm7DzTzE4X-jxHA@mail.gmail.com>
 <20110628210434.GD2121496@jupiter.n2.diac24.net>
 <BANLkTikN_TPPcyywVT5W9CrGAFJX8qQiyQ@mail.gmail.com>
 <20110628214637.GE2121496@jupiter.n2.diac24.net>
 <BANLkTi=4-xYNyaBOzeL04VioK8D0Q8secg@mail.gmail.com>
 <20110629163423.1d73b0ef@nehalam.ftrdhcpuser.net>
 <20110701101625.GB3988422@jupiter.n2.diac24.net>
 <BANLkTimjnP87CAA7JVAe5hqeP08Hd7766g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Lamparter <equinox@diac24.net>,
	Stephen Hemminger <shemminger@linux-foundation.org>,
	Nick Carter <ncarter100@gmail.com>, netdev@vger.kernel.org,
	davem@davemloft.net
To: =?utf-8?B?TWljaGHFgiBNaXJvc8WCYXc=?= <mirqus@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from spaceboyz.net ([87.106.131.203]:36954 "EHLO spaceboyz.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751842Ab1GAPQg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 1 Jul 2011 11:16:36 -0400
Content-Disposition: inline
In-Reply-To: <BANLkTimjnP87CAA7JVAe5hqeP08Hd7766g@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jul 01, 2011 at 04:58:56PM +0200, Micha=C5=82 Miros=C5=82aw wro=
te:
[...]
> > We _MUST_NOT_ pass bonding frames in any case, but we
> > currently do that if STP is off. (cf. my earlier patch 1/2)
>=20
> If you use linux box as a (invisible) L2 network tap, then you want t=
o
> pass everything in the hub mode (including LACP/whatever).

We must not do that by default, this breaks bridges with bonding device=
s
as ports. I'm actively band-aiding that problem with ebtables on one of
my boxes currently.

How about I change "stp_forward_802local" to "forward_802local" and it
gets 3 values like:
- 0 (default) behave like a switch, if STP is on then drop all 16
  groups, if STP is off then drop :01 and :02
- 1 forward regular groups - drop :01 and :02, forward everything else
- 2 forward everything ("invisible tap mode")
optional:
- -1 drop all 16 groups even if STP is off (not needed, can be done wit=
h
  ebtables...)

btw, since the drivers should eat up pause frames, you're not a fully
invisible L2 tap anyway.


-David

