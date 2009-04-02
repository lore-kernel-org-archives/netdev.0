From: Gregory Haskins <ghaskins@novell.com>
Subject: Re: [RFC PATCH 00/17] virtual-bus
Date: Thu, 02 Apr 2009 06:46:57 -0400
Message-ID: <49D497A1.4090900@novell.com>
References: <20090331184057.28333.77287.stgit@dev.haskins.net> <87ab71monw.fsf@basil.nowhere.org> <49D35825.3050001@novell.com> <20090401132340.GT11935@one.firstfloor.org> <49D37805.1060301@novell.com> <20090401170103.GU11935@one.firstfloor.org> <49D3B64F.6070703@codemonkey.ws> <49D3D7EE.4080202@novell.com> <49D46089.5040204@redhat.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="------------enigC0794BE13A6673D09C06C56B"
Cc: Anthony Liguori <anthony@codemonkey.ws>,
	Andi Kleen <andi@firstfloor.org>, linux-kernel@vger.kernel.org,
	agraf@suse.de, pmullaney@novell.com, pmorreale@novell.com,
	rusty@rustcorp.com.au, netdev@vger.kernel.org, kvm@vger.kernel.org
To: Avi Kivity <avi@redhat.com>
Return-path: <kvm-owner@vger.kernel.org>
In-Reply-To: <49D46089.5040204@redhat.com>
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 2440 and 3156)
--------------enigC0794BE13A6673D09C06C56B
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

Avi Kivity wrote:
> Gregory Haskins wrote:
>>
>>
>> I think there is a slight disconnect here.  This is *exactly* what I a=
m
>> trying to do.  You can of course do this many ways, and I am not denyi=
ng
>> it could be done a different way than the path I have chosen.  One
>> extreme would be to just slam a virtio-net specific chunk of code
>> directly into kvm on the host.  Another extreme would be to build a
>> generic framework into Linux for declaring arbitrary IO types,
>> integrating it with kvm (as well as other environments such as lguest,=

>> userspace, etc), and building a virtio-net model on top of that.
>>
>> So in case it is not obvious at this point, I have gone with the latte=
r
>> approach.  I wanted to make sure it wasn't kvm specific or something
>> like pci specific so it had the broadest applicability to a range of
>> environments.  So that is why the design is the way it is.  I understa=
nd
>> that this approach is technically "harder/more-complex" than the "slam=

>> virtio-net into kvm" approach, but I've already done that work.  All w=
e
>> need to do now is agree on the details ;)
>>
>>  =20
>
> virtio is already non-kvm-specific (lguest uses it) and
> non-pci-specific (s390 uses it).

Ok, then to be more specific, I need it to be more generic than it
already is.  For instance, I need it to be able to integrate with
shm_signals.  If we can do that without breaking the existing ABI, that
would be great!  Last I looked, it was somewhat entwined here so I didnt
try...but I admit that I didnt try that hard since I already had the IOQ
library ready to go.

>
>>> That said, I don't think we're bound today by the fact that we're in
>>> userspace.
>>>    =20
>> You will *always* be bound by the fact that you are in userspace.  Its=

>> purely a question of "how much" and "does anyone care".    Right now,
>> the anwer is "a lot (roughly 45x slower)" and "at least Greg's custome=
rs
>> do".  I have no doubt that this can and will change/improve in the
>> future.  But it will always be true that no matter how much userspace
>> improves, the kernel based solution will always be faster.  Its simple=

>> physics.  I'm cutting out the middleman to ultimately reach the same
>> destination as the userspace path, so userspace can never be equal.
>>  =20
>
> If you have a good exit mitigation scheme you can cut exits by a
> factor of 100; so the userspace exit costs are cut by the same
> factor.  If you have good copyless networking APIs you can cut the
> cost of copies to zero (well, to the cost of get_user_pages_fast(),
> but a kernel solution needs that too).

"exit mitigation' schemes are for bandwidth, not latency.  For latency
it all comes down to how fast you can signal in both directions.  If
someone is going to do a stand-alone request-reply, its generally always
going to be at least one hypercall and one rx-interrupt.  So your speed
will be governed by your signal path, not your buffer bandwidth.

What Ive done is shown that you can use techniques other than buffering
the head of the queue to do exit mitigation for bandwidth, while still
maintaining a very short signaling path for latency.  And I also argue
that the latter will always be optimal in the kernel, though I know by
which degree is still TBD.  Anthony thinks he can make the difference
negligible, and I would love to see it but am skeptical.

-Greg




--------------enigC0794BE13A6673D09C06C56B
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.9 (GNU/Linux)
Comment: Using GnuPG with SUSE - http://enigmail.mozdev.org

iEYEARECAAYFAknUl6IACgkQlOSOBdgZUxkZRACdEdkCZboECmDSqpnPpzbQ+e14
3HQAn3UDVPgUqIIAqFO7Yykk7wimIwqd
=DdVe
-----END PGP SIGNATURE-----

--------------enigC0794BE13A6673D09C06C56B--
