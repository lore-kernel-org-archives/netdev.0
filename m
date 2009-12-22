From: Gregory Haskins <gregory.haskins@gmail.com>
Subject: Re: [GIT PULL] AlacrityVM guest drivers for 2.6.33
Date: Tue, 22 Dec 2009 14:32:27 -0500
Message-ID: <4B311ECB.6040205@gmail.com>
References: <4B1D4F29.8020309@gmail.com> <20091218215107.GA14946@elte.hu> <4B2F9582.5000002@gmail.com> <20091222075742.GB26467@elte.hu> <4B3103B4.4070708@gmail.com> <4B3115C1.4070303@redhat.com> <4B311ADA.4000700@gmail.com> <4B311D20.7020400@redhat.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="------------enig933A54EB715F664AF186183B"
Cc: Ingo Molnar <mingo@elte.hu>, kvm@vger.kernel.org,
	Andrew Morton <akpm@linux-foundation.org>,
	torvalds@linux-foundation.org,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	netdev@vger.kernel.org,
	"alacrityvm-devel@lists.sourceforge.net"
	<alacrityvm-devel@lists.sourceforge.net>
To: Avi Kivity <avi@redhat.com>
Return-path: <kvm-owner@vger.kernel.org>
In-Reply-To: <4B311D20.7020400@redhat.com>
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 2440 and 3156)
--------------enig933A54EB715F664AF186183B
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

On 12/22/09 2:25 PM, Avi Kivity wrote:
> On 12/22/2009 09:15 PM, Gregory Haskins wrote:
>> On 12/22/09 1:53 PM, Avi Kivity wrote:
>>  =20
>>> I asked why the irqfd/ioeventfd mechanisms are insufficient, and you
>>> did not reply.
>>>
>>>     =20
>> BTW: the ioeventfd issue just fell through the cracks, so sorry about
>> that.  Note that I have no specific issue with irqfd ever since the
>> lockless IRQ injection code was added.
>>
>> ioeventfd turned out to be suboptimal for me in the fast path for two
>> reasons:
>>
>> 1) the underlying eventfd is called in atomic context.  I had posted
>> patches to Davide to address that limitation, but I believe he rejecte=
d
>> them on the grounds that they are only relevant to KVM.
>>   =20
>=20
> If you're not doing something pretty minor, you're better of waking up =
a
> thread (perhaps _sync if you want to keep on the same cpu).  With the
> new user return notifier thingie, that's pretty cheap.

We have exploits that take advantage of IO heuristics.  When triggered
they do more work in vcpu context than normal, which reduces latency
under certain circumstances.  But you definitely do _not_ want to do
them in-atomic ;)

>=20
>> 2) it cannot retain the data field passed in the PIO.  I wanted to hav=
e
>> one vector that could tell me what value was written, and this cannot =
be
>> expressed in ioeventfd.
>>
>>   =20
>=20
> It would be easier to add data logging support to ioeventfd, if it was
> needed that badly.

"Better design"? perhaps.  "More easily"?  no.  Besides, Davide has
already expressed dissatisfaction with the KVM-isms creeping into
eventfd, so its not likely to ever be accepted regardless of your own
disposition.

xinterface, as it turns out, is a great KVM interface for me and easy to
extend, all without conflicting with the changes in upstream.  The old
way was via the kvm ioctl interface, but that sucked as the ABI was
always moving.  Where is the problem?  ioeventfd still works fine as it i=
s.

Kind Regards,
-Greg



--------------enig933A54EB715F664AF186183B
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG/MacGPG2 v2.0.11 (Darwin)
Comment: Using GnuPG with Mozilla - http://enigmail.mozdev.org/

iEYEARECAAYFAksxHssACgkQP5K2CMvXmqEwlQCdFszWrw9+/J0udBfJSeaMKH5K
uf0AnjqTzUTYJNj+z7jjHV+LJLWeYW6X
=cCLx
-----END PGP SIGNATURE-----

--------------enig933A54EB715F664AF186183B--
