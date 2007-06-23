From: David Stevens <dlstevens@us.ibm.com>
Subject: Re: [RFD] First draft of RDNSS-in-RA support for IPv6 DNS autoconfiguration
Date: Sat, 23 Jun 2007 11:51:10 -0700
Message-ID: <OF8A941F0F.60C57774-ON88257303.0064A759-88257303.006782B8@us.ibm.com>
References: <200706232113.01745@auguste.remlab.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: cananian@gmail.com, "C. Scott Ananian" <cscott@laptop.org>,
	netdev@vger.kernel.org
To: =?ISO-8859-1?Q?R=E9mi_Denis-Courmont?= <rdenis@simphalempin.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e35.co.us.ibm.com ([32.97.110.153]:57058 "EHLO
	e35.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754301AbXFWSvQ convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 23 Jun 2007 14:51:16 -0400
Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by e35.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id l5NIpFfh017938
	for <netdev@vger.kernel.org>; Sat, 23 Jun 2007 14:51:15 -0400
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by d03relay04.boulder.ibm.com (8.13.8/8.13.8/NCO v8.3) with ESMTP id l5NIpFfA216256
	for <netdev@vger.kernel.org>; Sat, 23 Jun 2007 12:51:15 -0600
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l5NIpFIo027248
	for <netdev@vger.kernel.org>; Sat, 23 Jun 2007 12:51:15 -0600
In-Reply-To: <200706232113.01745@auguste.remlab.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

R=E9mi Denis-Courmont <rdenis@simphalempin.com> wrote on 06/23/2007 11:=
13:01=20
AM:

>    An implementation might perform additional validity checks on the
>    ICMPv6 message content and discard malformed packets.  However, a
>    portable application must not assume that such validity checks hav=
e
>    been performed.

        This doesn't say that unauthenticated packets must be delivered=
,
and I don't think the portability of an RDNS daemon is an issue. But
even if you really wanted to run the same code on a non-Linux machine,
it just means that your daemon code would have to do its own=20
authentication.
Reading /proc or netlink with packet formats you've defined to get this
information is not more portable to non-Linux machines, right?
        I don't see any issue here. If an application is relying on the
ability to see forged packets for portability reasons, it's probably no=
t
an application you want running on your machine. :-)

> That would encourage people into running open recursive DNS servers=20
> which is widely known and documented as a bad practice. Definitely a=20
> very bad idea.
        I don't understand your point here. I'm talking about client
behaviour, and if the client fails for a server from a downed interface=
,
I don't see how that's different from removing the client from the
list, which is what you want to do. Nobody should feel encouraged to
do anything different on the server side-- at least not by me!
=20
> > But if you really need it, you can monitor netlink, or poll the
> > interface flags on whatever interval you require for detection.
>=20
> >         As for autoconf, that's available from sysctl, I assume fro=
m
> > /proc somewhere, too. That usually doesn't change, but if you want =
to
> > account for runtime configuration changes, you can always monitor
> > netlink and reread when new addresses appear, too.
>=20
> There are a bunch of parameters that determine whether an interface=20
> accepts RAs or not. I doubt it's wise to try to reimplement that into=
=20
> userspace, particularly if it is subject to change.

        I'm not suggesting re-implementing anything; I'm saying you can
read the current state at application level, if you need it. If you
think it's difficult to get the correct information from existing
API's, then improving those API's is always worthwhile. I don't
believe it's excessively difficult to determine if autoconf is in
use, though.

> My point=20
> is raw IPv6 sockets are not usable for the time being, and I do not s=
ee=20
> anyway to fix without modifying the kernel.

I disagree about raw sockets being usable, but "without modifying the
kernel" isn't a constraint.
"modifying the kernel" !=3D "put DNS server info in the kernel";
if there's a bug, or some minor tweaking that'd help the feature along,
I'd support that. The important point for me is that the basic mechanis=
ms
are already in place, and I think it'd be best to use those rather than
creating a new interface for all of this.

> The userspace DNS configuration daemon might need to be started later=
=20
> than the kernel autoconf - another issue that needs help from the=20
> kernel.
        Easily done; the init scripts are what bring the interfaces up
in the first place, so start the daemon before those run. Adding an
entry in inittab so it'll be automatically restarted if it dies is also
a reasonable thing. RA's are resent periodically, and they can be lost
anyway, so not the end of the world if you miss one, either.

                                                                +-DLS

