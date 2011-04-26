From: "Rose, Gregory V" <gregory.v.rose@intel.com>
Subject: RE: [RFC PATCH] netlink: Increase netlink dump skb message size
Date: Tue, 26 Apr 2011 09:12:26 -0700
Message-ID: <43F901BD926A4E43B106BF17856F0755018DC497D4@orsmsx508.amr.corp.intel.com>
References: <20110425220157.2012.96707.stgit@gitlad.jf.intel.com>
	<1303799597.2747.214.camel@edumazet-laptop>
 <20110425.235600.104065244.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"bhutchings@solarflare.com" <bhutchings@solarflare.com>
To: David Miller <davem@davemloft.net>,
	"eric.dumazet@gmail.com" <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:1972 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754236Ab1DZQM3 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Apr 2011 12:12:29 -0400
In-Reply-To: <20110425.235600.104065244.davem@davemloft.net>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> -----Original Message-----
> From: David Miller [mailto:davem@davemloft.net]
> Sent: Monday, April 25, 2011 11:56 PM
> To: eric.dumazet@gmail.com
> Cc: Rose, Gregory V; netdev@vger.kernel.org; bhutchings@solarflare.co=
m
> Subject: Re: [RFC PATCH] netlink: Increase netlink dump skb message s=
ize
>=20
> From: Eric Dumazet <eric.dumazet@gmail.com>
> Date: Tue, 26 Apr 2011 08:33:17 +0200
>=20
> > Le lundi 25 avril 2011 =E0 15:01 -0700, Greg Rose a =E9crit :
> >> The message size allocated for rtnl info dumps was limited to a si=
ngle
> page.
> >> This is not enough for additional interface info available with de=
vices
> >> that support SR-IOV.  Check that the amount of data allocated is
> sufficient
> >> for the amount of data requested.
> >>
> >> Signed-off-by: Greg Rose <gregory.v.rose@intel.com>
> >> ---
> >>
> >>  include/linux/rtnetlink.h |    1 +
> >>  net/core/rtnetlink.c      |    6 ++++++
> >>  net/netlink/af_netlink.c  |   37 +++++++++++++++++++++++++++++++-=
-----
> >>  3 files changed, 38 insertions(+), 6 deletions(-)
> >>
> >
> > Hmm, thats a hack, because netlink_dump() is generic and you add
> > something very specific.
>=20
> You also can't do this without breaking applications.
>=20
> We've trained every single netlink library out there about this messa=
ge
> size
> formula, so they know that if you allocate at least 8192 bytes for a
> recvmsg()
> call they can receive fully any single netlink message.

I checked the message sizes being generated and they were far less than=
 8K for 63 VFs and from my calculation would still be less than 8K for =
127 VFs as per Ben Hutching's requirements.  I thought I had 16k to wor=
k with as that is what is allocated by the iproute2 ip application also=
 as per Ben's prior email.  I checked and that is the case.  But whatev=
er the case I think we're still fine for 8K.  I could put a check in to=
 make sure alloc_size doesn't go over 8k.

>=20
> And they must be able to make assumptions like this, otherwise they
> cannot know how to reliably be able to receive a netlink message in
> it's entirety in a generic fashion.
>=20
> So one must not attack this problem from this angle.

This was just a bug fix.  If you recall the email thread from last week=
 that brought up this whole thing I was advocating for an entirely new =
angle myself.  If the bug fix causes more problems than it solves, and =
that's not rare by any means, then we can toss it and go back to the st=
art.

>=20
> It is absolutely necessary to find some way to report the VF
> information, out of band, instead of trying to make the message
> larger.

Absolutely agreed!

>=20
> Needing more than 8K to get a dump of a single device over netlink is
> absolutely rediculious, this VF stuff was poorly designed.  If has to
> be fixed and the current stuff marked deprecated.

Again, absolutely no argument from me.

And I have an idea as to how to do this but Ben asked me to come up wit=
h a bug fix first and then work on the extensions that would do just wh=
at you're saying here later.  I'm fine with dropping the bug fix hack a=
nd getting back to my original ideas on the subject.  The problem there=
 is that due to my work load it would be a month or more before I could=
 finish it up and meanwhile the bug still exists.

I'm fine with however you folks want to approach this, just give me som=
e direction.

- Greg

