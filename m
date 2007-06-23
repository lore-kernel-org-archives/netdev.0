From: =?iso-8859-1?q?R=E9mi_Denis-Courmont?= <rdenis@simphalempin.com>
Subject: Re: [RFD] First draft of RDNSS-in-RA support for IPv6 DNS autoconfiguration
Date: Sat, 23 Jun 2007 21:13:01 +0300
Message-ID: <200706232113.01745@auguste.remlab.net>
References: <OFBCA57EE5.DABFEB20-ON88257303.00601DB3-88257303.00618B1D@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: cananian@gmail.com, "C. Scott Ananian" <cscott@laptop.org>,
	netdev@vger.kernel.org
To: David Stevens <dlstevens@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from poy.chewa.net ([194.242.114.73]:1235 "EHLO poy.chewa.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753996AbXFWSNG convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 23 Jun 2007 14:13:06 -0400
In-Reply-To: <OFBCA57EE5.DABFEB20-ON88257303.00601DB3-88257303.00618B1D@us.ibm.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le samedi 23 juin 2007, David Stevens a =E9crit :
>         The kernel should do the authentication, as it will for other
> RA's,
> and should not deliver (IMAO) unauthenticated packets. If it is, I
> would consider that a bug (for all cases, not just this), and that
> would be a good thing to fix. :-)

I am all for an interface whereby the kernel queues all "accepted" RAs=20
for userland to process additionnal parameters... but that's totally=20
NOT how ICMPv6 raw sockets currently work, and it would be a very=20
significant departure from the Advanced IPv6 Socket API (RFC 3542, in=20
particular =A73.3):

   An implementation might perform additional validity checks on the
   ICMPv6 message content and discard malformed packets.  However, a
   portable application must not assume that such validity checks have
   been performed.

Being malformed does not include failing authentication, or the local=20
host not using autoconf. I am all for a setsockopt() that limits=20
delivery to "accepted" RAs, but it does not currently exist.

>         An interface going down doesn't directly invalidate a DNS
> server address, though it may not be the best through another
> interface. Since it is a list, I think "doing nothing" for this case
> wouldn't be terrible. This is no worse than the existing resolver
> code.

That would encourage people into running open recursive DNS servers=20
which is widely known and documented as a bad practice. Definitely a=20
very bad idea.

> But if you really need it, you can monitor netlink, or poll the
> interface flags on whatever interval you require for detection.

>         As for autoconf, that's available from sysctl, I assume from
> /proc somewhere, too. That usually doesn't change, but if you want to
> account for runtime configuration changes, you can always monitor
> netlink and reread when new addresses appear, too.

There are a bunch of parameters that determine whether an interface=20
accepts RAs or not. I doubt it's wise to try to reimplement that into=20
userspace, particularly if it is subject to change.

>         There certainly may be complications I haven't thought of,
> since I haven't implemented it. But I still don't see a good case for
> using the kernel as a DNS database.

I never said the kernel needed to parse DNS messages by itself. My poin=
t=20
is raw IPv6 sockets are not usable for the time being, and I do not see=
=20
anyway to fix without modifying the kernel.

The userspace DNS configuration daemon might need to be started later=20
than the kernel autoconf - another issue that needs help from the=20
kernel.

--=20
R=E9mi Denis-Courmont
http://www.remlab.net/
