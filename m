From: Gregory Haskins <gregory.haskins@gmail.com>
Subject: Re: [GIT PULL] AlacrityVM guest drivers for 2.6.33
Date: Mon, 21 Dec 2009 12:24:35 -0500
Message-ID: <4B2FAF53.2080601@gmail.com>
References: <4B1D4F29.8020309@gmail.com> <20091218215107.GA14946@elte.hu> <4B2F9582.5000002@gmail.com> <4B2F978D.7010602@redhat.com> <4B2F9C85.7070202@gmail.com> <4B2FA42F.3070408@codemonkey.ws> <4B2FA4F2.8000401@redhat.com> <4B2FA8D4.3050206@gmail.com> <4B2FAAC2.4080007@redhat.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="------------enig7DB66DFC581A71169F230928"
Cc: Anthony Liguori <anthony@codemonkey.ws>,
	Ingo Molnar <mingo@elte.hu>, kvm@vger.kernel.org,
	Andrew Morton <akpm@linux-foundation.org>,
	torvalds@linux-foundation.org,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	netdev@vger.kernel.org,
	"alacrityvm-devel@lists.sourceforge.net"
	<alacrityvm-devel@lists.sourceforge.net>
To: Avi Kivity <avi@redhat.com>
Return-path: <kvm-owner@vger.kernel.org>
In-Reply-To: <4B2FAAC2.4080007@redhat.com>
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 2440 and 3156)
--------------enig7DB66DFC581A71169F230928
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

On 12/21/09 12:05 PM, Avi Kivity wrote:
> On 12/21/2009 06:56 PM, Gregory Haskins wrote:
>>> I'm working on disappearing EOI exits on older hardware as well.  Sam=
e
>>> idea as the old TPR patching, without most of the magic.
>>>
>>>     =20
>> While I applaud any engineering effort that results in more optimal
>> execution, if you are talking about what we have discussed in the past=

>> its not quite in the same league as my proposal.
>>   =20
>=20
> I don't doubt this for a minute.
>=20
>> You are talking about the ability to optimize the final EOI if there a=
re
>> no pending interrupts remaining, right?  The problem with this approac=
h
>> is it addresses the wrong side of the curve: That is, it optimizes the=

>> code as its about to go io-idle.  You still have to take an extra exit=

>> for each injection during the heat of battle, which is when you actual=
ly
>> need it most.
>>   =20
>=20
> No, it's completely orthogonal.  An interrupt is injected, the handler
> disables further interrupts and EOIs, then schedules the rest of the
> handling code.  So long as there as packets in the ring interrupts won'=
t
> be enabled and hence there won't be any reinjections.

I meant inter-vector "next-interrupt" injects.  For lack of a better
term, I called it reinject, but I realize in retrospect that this is
ambiguous.

>=20
> Different interrupt sources still need different interrupts, but as all=

> of your tests have been single-interface, this can't be the reason for
> your performance.
>=20

Actually I have tested both single and multi-homed setups, but it
doesn't matter.  Even a single device can benefit, as even single
devices may have multiple vector sources that are highly probably to
generate coincident events.  For instance, consider that even a basic
ethernet may have separate vectors for "rx" and "tx-complete".  A simple
ping is likely to generate both vectors at approximately the same time,
given how the host side resources often work.

Trying to condense multiple vectors into one means its up to the driver
to implement any type of prioritization on its own (or worse, it just
suffers from PI).  Likewise, implementing them as unique vectors means
you are likely to have coincident events for certain workloads.

What alacrityvm tries to do is recognize these points and optimize for
both cases.  It means we still retain framework-managed prioritized
callbacks, yet optimize away extraneous IO for coincident signals.  IOW:
best of both worlds.

Kind Regards,
-Greg




--------------enig7DB66DFC581A71169F230928
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG/MacGPG2 v2.0.11 (Darwin)
Comment: Using GnuPG with Mozilla - http://enigmail.mozdev.org/

iEYEARECAAYFAksvr1MACgkQP5K2CMvXmqFBcACeOvRNnYLTTOrAF4ruBwa/8+FW
cJsAoIohTHET9ppV/I69WdKWvdnsXiQo
=LNja
-----END PGP SIGNATURE-----

--------------enig7DB66DFC581A71169F230928--
