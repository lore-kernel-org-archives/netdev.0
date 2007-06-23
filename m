From: David Stevens <dlstevens@us.ibm.com>
Subject: Re: [RFD] First draft of RDNSS-in-RA support for IPv6 DNS autoconfiguration
Date: Sat, 23 Jun 2007 10:45:59 -0700
Message-ID: <OFBCA57EE5.DABFEB20-ON88257303.00601DB3-88257303.00618B1D@us.ibm.com>
References: <200706231952.03096@auguste.remlab.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: cananian@gmail.com, "C. Scott Ananian" <cscott@laptop.org>,
	netdev@vger.kernel.org
To: =?ISO-8859-1?Q?R=E9mi_Denis-Courmont?= <rdenis@simphalempin.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e33.co.us.ibm.com ([32.97.110.151]:44831 "EHLO
	e33.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753224AbXFWRqF convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 23 Jun 2007 13:46:05 -0400
Received: from d03relay02.boulder.ibm.com (d03relay02.boulder.ibm.com [9.17.195.227])
	by e33.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id l5NHk54l010956
	for <netdev@vger.kernel.org>; Sat, 23 Jun 2007 13:46:05 -0400
Received: from d03av01.boulder.ibm.com (d03av01.boulder.ibm.com [9.17.195.167])
	by d03relay02.boulder.ibm.com (8.13.8/8.13.8/NCO v8.3) with ESMTP id l5NHk4CT270788
	for <netdev@vger.kernel.org>; Sat, 23 Jun 2007 11:46:04 -0600
Received: from d03av01.boulder.ibm.com (loopback [127.0.0.1])
	by d03av01.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l5NHk4Ws005527
	for <netdev@vger.kernel.org>; Sat, 23 Jun 2007 11:46:04 -0600
In-Reply-To: <200706231952.03096@auguste.remlab.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

R=E9mi Denis-Courmont <rdenis@simphalempin.com> wrote on 06/23/2007 09:=
51:55=20
AM:

> How do I authenticate SeND RA? How do I deal with the link going down=
=20
> before the expiration? How do I know "this" interface is doing autoco=
nf=20
> at all?

        The kernel should do the authentication, as it will for other=20
RA's,
and should not deliver (IMAO) unauthenticated packets. If it is, I woul=
d
consider that a bug (for all cases, not just this), and that would be a
good thing to fix. :-)
        An interface going down doesn't directly invalidate a DNS serve=
r
address, though it may not be the best through another interface. Since
it is a list, I think "doing nothing" for this case wouldn't be terribl=
e.
This is no worse than the existing resolver code. But if you really nee=
d=20
it,
you can monitor netlink, or poll the interface flags on whatever interv=
al=20
you
require for detection.
        As for autoconf, that's available from sysctl, I assume from /p=
roc
somewhere, too. That usually doesn't change, but if you want to account
for runtime configuration changes, you can always monitor netlink and
reread when new addresses appear, too.

        There certainly may be complications I haven't thought of, sinc=
e
I haven't implemented it. But I still don't see a good case for using t=
he
kernel as a DNS database.

                                                                +-DLS

