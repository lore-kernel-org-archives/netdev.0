From: "John A. Sullivan III" <jsullivan@opensourcedevel.com>
Subject: Re: Optimizing tc filters
Date: Sat, 10 Dec 2011 14:58:00 -0500
Message-ID: <1323547080.3159.153.camel@denise.theartistscloset.com>
References: <1323540988.3159.133.camel@denise.theartistscloset.com>
	 <1323546064.4016.27.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.perfora.net ([74.208.4.194]:56758 "EHLO mout.perfora.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751091Ab1LJT6F convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 10 Dec 2011 14:58:05 -0500
In-Reply-To: <1323546064.4016.27.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 2011-12-10 at 20:41 +0100, Eric Dumazet wrote:
> Le samedi 10 d=C3=A9cembre 2011 =C3=A0 13:16 -0500, John A. Sullivan =
III a =C3=A9crit :
> > Hello, all.  Given that there are several ways to direct packets in=
to
> > the appropriate queue, I was wondering which ways are generally mor=
e
> > efficient.  There seem to be a number of email discussions but noth=
ing
> > authoritative.  From those discussions, it would seem that for most
> > corporate usage (as in more traffic than a home user) we would have=
 from
> > most efficient to least efficient:
> >=20
> > 1) Mark the connection with CONNMARK and us --restore-mark to mark =
all
> > packets in the connection for classification via an fw filter
> >=20
> > 2) Use the iptables CLASSIFY target
> >=20
> > 3) u32 filter
> >=20
> > 4) Mark individual packets and use an fw filter - one email thread =
says
> > this is more efficient than #3
> >=20
> > Is this correct?
>=20
> Unfortunately CONNTRACK is a bit expensive...
>=20
> If you control applications, you also can use SO_MARK from them.
>=20
>=20
>=20
OK.  Does that mean that #1 is actually #4?

If we are using connection tracking in general to produce a "stateful"
firewall (let's just say we are - I certainly don't want to set off a
debate :) ), does that put #1 back on top as the most efficient since w=
e
are incurring the conntrack overhead anyway or does the CONNMARK target
itself add considerable overhead? Thanks - John
