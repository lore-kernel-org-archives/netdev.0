From: David Lamparter <equinox@diac24.net>
Subject: Re: [PATCH] bridge: revisit IEEE 802 local multicast groups
Date: Fri, 1 Jul 2011 18:40:01 +0200
Message-ID: <20110701164001.GD2613105@jupiter.n2.diac24.net>
References: <1309518770-8547-1-git-send-email-equinox@diac24.net>
 <20110701092612.07b045bf@nehalam.ftrdhcpuser.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Lamparter <equinox@diac24.net>, netdev@vger.kernel.org,
	Nick Carter <ncarter100@gmail.com>
To: Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from spaceboyz.net ([87.106.131.203]:37591 "EHLO spaceboyz.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757182Ab1GAQkI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 1 Jul 2011 12:40:08 -0400
Content-Disposition: inline
In-Reply-To: <20110701092612.07b045bf@nehalam.ftrdhcpuser.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jul 01, 2011 at 09:26:12AM -0700, Stephen Hemminger wrote:
> On Fri,  1 Jul 2011 13:12:50 +0200
> David Lamparter <equinox@diac24.net> wrote:
>=20
> > this first and foremost fixes handling of bonding frames, which wer=
e
> > incorrectly forwarded until now. they need to never cross a bridge.
> >=20
> > it also introduces a new switch to control handling of the other
> > not-that-special groups; if you want them forwarded despite having
> > STP running, there's a sysfs knob for that. you can implement your
> > local policy with ebtables then.
> >=20
> > in the end, we now match hardware switch behaviour rather closely, =
but
> > still additionally allow playing tricks on things like 802.1X.
> >=20
> > Signed-off-by: David Lamparter <equinox@diac24.net>
> > Cc: Stephen Hemminger <shemminger@linux-foundation.org>
> > Cc: Nick Carter <ncarter100@gmail.com>
>=20
> Forwarding pause frames is wrong.

None of the patches discussed forwards pause frames.

> I wonder if the best solution for this crap is to just write
> a userland program to do the forwarding.

You can't do that without moving the remaining STP bits to userspace,
since if you want to keep STP in-kernel, you still need some policy.

Also, there is a fundamental conflict between a working bridge and the
desire to work as fully transparent L2 tap. As long as we forward
802.3ad/bonding frames, we are a broken bridge. Yet we still want that
for the tap case.

Plus, we don't need the userspace daemon if we can set the policy with
ebtables - which we can do if and only if we allow stripping down the
built-in restrictions.

I think the variant that I suggested to Micha=C5=82, with a 3-value kno=
b
"drop it if STP" / "forward except pause/bond" / "forward all" is
the best way to go. It leaves the default usable but allows controlling
everything through ebtables.


-David

