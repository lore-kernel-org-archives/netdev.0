From: Christian Grothoff <christian@grothoff.org>
Subject: Re: [PATCH] TCP: Add support for TCP Stealth
Date: Fri, 02 Jan 2015 15:06:10 +0100
Message-ID: <54A6A5D2.1050806@grothoff.org>
References: <54A470B3.3010501@sec.in.tum.de> <54A566F2.4070401@redhat.com> <54A56880.6040802@grothoff.org> <54A69430.2060800@redhat.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="oh33XrNp2rkwNipAP7sPvpfobdQV5UQa8"
Cc: Julian Kirsch <kirschju@sec.in.tum.de>, netdev@vger.kernel.org,
	Jacob Appelbaum <jacob@appelbaum.net>,
	Pavel Emelyanov <xemul@parallels.com>
To: Daniel Borkmann <dborkman@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.informatik.tu-muenchen.de ([131.159.0.99]:33352 "EHLO
	smtp1.informatik.tu-muenchen.de" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751950AbbABOGI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 2 Jan 2015 09:06:08 -0500
In-Reply-To: <54A69430.2060800@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--oh33XrNp2rkwNipAP7sPvpfobdQV5UQa8
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable

On 01/02/2015 01:50 PM, Daniel Borkmann wrote:
> On 01/01/2015 04:32 PM, Christian Grothoff wrote:
> ...
>> That approach is highly vulnerable to timing attacks, and doesn't answ=
er
>> how TCP clients without special capabilities could set the ISN correct=
ly
>> either. Playing with raw sockets is the kind of geeky hack that is
>=20
> Right, for client/server side you'd need to have the capabilities and
> then drop them later, which would make that approach less convenient
> for user space applications (despite not having to have a port knocking=

> uapi in the TCP core itself). For the server, you might get away with a=

> central daemon spawning sockets via IPC, but for the unprivileged
> client to e.g., let it set it's own ISN via setsockopt(2) would be a
> bad idea.
>=20
>> unlikely to give us the combination of usability and security required=

>> to significantly reduce the ongoing large-scale compromise of network
>> equipment by spy agencies.
>=20
> Out of curiosity, when you say you want to significantly reduce the
> large-scale compromise of services by hiding ports, how do you solve
> i) the pre-shared key distribution issue you need for your approach
> (are you mostly targeting administrators for accessing their companies
> router/firewall management interfaces?),=20

Our assumption is that this solution will work if SSH access to the
system is limited to a small set of users that can easily agree on an
additional passphrase.  We do not claim to solve the key distribution
issue in general (the GNU Name System can solve it for some application
scenarios, but that's out of scope for Knock).  Like most security
solutions, this works for some scenarios, but not all.

> and ii) the broad adoption of
> this setsockopt(2) in applications? I think for ii) it would be great
> not having to change and recompile every possible client _and_ server
> application if they don't have the change upstreamed in their project.

Correct, for that we have libknockify, a library you can LD_PRELOAD,
setting the passphrase via an environment variable.  Now, this doesn't
work for applications that don't permit LD_PRELOAD (like openssh) or use
some TCP sockets where TCP Stealth should be active, and others where it
should not be.  But for tools like 'netcat', 'telnet', 'wget' and many
other small tools, libknockify will work.

> It feels like a property that goes beyond the scope of a specific,
> individual application, put differently, what about an additional
> central configuration interface?

With our patch for systemd support, we kind of have a 'central'
configuration interface for "next-generation" servers that support
systemd-style listening.  For clients, using libknockify works usually
pretty well as clients usually don't have many different types of TCP
sockets open.

> Other than that, is there a plan for
> key rotations in other words, to have a grace period for a key
> transition as peers might not have synced clocks?

I have no such plans, as it would complicate the system quite a bit and
thus also reduces usability.  It would way complicate the key
distribution issue you mentioned, and also the libknockify-style
integration where currently the PSK can simply be passed via an
environment variable would also have to be done differently (i.e.
contacting some kind of PSK-oracle service via IPC). The result would be
a huge increase in complexity for IMO a rather small gain in security
for possibly only a small set of users.


--oh33XrNp2rkwNipAP7sPvpfobdQV5UQa8
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIcBAEBAgAGBQJUpqXTAAoJEJOea+Hin8PMnGoP/i1TKo4hzEafLt+0HNVEveo4
4p9+qIK434Peu6XmQPX8IEyiyrizYeq474aVnlqQWKa3+Y986AR9xPgJtZu7k0IG
AHt0qfuTcFloeIkE6dbuCdqmtJ1+y5XxAWxQw8xTrH0NAn8XrtpQIq1wmFjDU1X+
mpkl1SFINNRtt4g99u6SPKl2goUJwOg9+N98AadigrYg4EAJfUiFrMVnWKum4ceS
sTnbIyAdIp5d2U5qwDyLM8DFg8XlTRUtwQzTV3V3D+OgEcKYNKgOTjfzZFwjzG2t
QMO43ZQ4/EKTkhk2xlVw/qtQ0kJXnUPkFo3m7KfCpTbkckCo6WyLCur0ooNAUKZk
f6LtIQ/UmzyUSjO8zR3zPWKYaCwaOyhnwjzAelGErDdAnWpm+LlYKIijeXw3EeQ2
RdxcfTrDYb5yRJS/BtKu2m9M3B+xb/YpG6n3gbXouX7U5q52uymzC0u91+vHi2/k
b+TThur4dgXMk7Bp/5/dAm/ATxBlEcJM1dRZA6z4OzwAp4hnhAwoETBPKW0OorN8
OD+neq7CF3B0kKmN0Ggi7KYzxLqOSzBoW9i3BKcTivfJCniInokJtciZOvP2lEdk
EN7Y0b4j/XM4uU6M0MqedArrHzNRmyqWb3vUok+liuiopMYsGP5f3s2BzV6CXiSk
f0Xh3ZSljpgwjaX34hLO
=eO6y
-----END PGP SIGNATURE-----

--oh33XrNp2rkwNipAP7sPvpfobdQV5UQa8--
