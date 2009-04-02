From: Gregory Haskins <ghaskins@novell.com>
Subject: Re: [RFC PATCH 00/17] virtual-bus
Date: Thu, 02 Apr 2009 10:05:13 -0400
Message-ID: <49D4C619.30404@novell.com>
References: <20090402085253.GA29932@gondor.apana.org.au> <49D487A6.407@redhat.com> <49D49C1F.6030306@novell.com> <200904022243.21088.rusty@rustcorp.com.au> <49D4B4A3.5070008@novell.com> <49D4B87D.2000202@redhat.com> <49D4BBFA.2040106@novell.com> <49D4BD50.4070402@redhat.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="------------enig15944E94B338D67A0EF2D94A"
Cc: Rusty Russell <rusty@rustcorp.com.au>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	anthony@codemonkey.ws, andi@firstfloor.org,
	linux-kernel@vger.kernel.org, agraf@suse.de, pmullaney@novell.com,
	pmorreale@novell.com, netdev@vger.kernel.org, kvm@vger.kernel.org
To: Avi Kivity <avi@redhat.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1759301AbZDBODZ@vger.kernel.org>
In-Reply-To: <49D4BD50.4070402@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 2440 and 3156)
--------------enig15944E94B338D67A0EF2D94A
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: quoted-printable

Avi Kivity wrote:
> Gregory Haskins wrote:
>> Avi Kivity wrote:
>> =20
>>> Gregory Haskins wrote:
>>>   =20
>>>> Rusty Russell wrote:
>>>> =20
>>>>     =20
>>>>> On Thursday 02 April 2009 21:36:07 Gregory Haskins wrote:
>>>>>            =20
>>>>>> You do not need to know when the packet is copied (which I current=
ly
>>>>>> do).  You only need it for zero-copy (of which I would like to
>>>>>> support,
>>>>>> but as I understand it there are problems with the reliability of
>>>>>> proper
>>>>>> callback (i.e. skb->destructor).
>>>>>>                    =20
>>>>> But if you have a UP guest,
>>>>>            =20
>>>> I assume you mean UP host ;)
>>>>
>>>>        =20
>>> I think Rusty did mean a UP guest, and without schedule-and-forget.
>>>    =20
>> That doesnt make sense to me, tho.  All the testing I did was a UP
>> guest, actually.  Why would I be constrained to run without the
>> scheduling unless the host was also UP?
>>  =20
>
> You aren't constrained.  And your numbers show it works.
>
>>>
>>> The problem is that we already have virtio guest drivers going severa=
l
>>> kernel versions back, as well as Windows drivers.  We can't keep
>>> changing the infrastructure under people's feet.
>>>    =20
>>
>> Well, IIUC the virtio code itself declares the ABI as unstable, so the=
re
>> technically *is* an out if we really wanted one.  But I certainly
>> understand the desire to not change this ABI if at all possible, and
>> thus the resistance here.
>>  =20
>
> virtio is a stable ABI.

Dang!  Scratch that.
>
>> However, theres still the possibility we can make this work in an ABI
>> friendly way with cap-bits, or other such features.  For instance, the=

>> virtio-net driver could register both with pci and vbus-proxy and
>> instantiate a device with a slightly different ops structure for each =
or
>> something.  Alternatively we could write a host-side shim to expose vb=
us
>> devices as pci devices or something like that.
>>  =20
>
> Sounds complicated...

Well, the first solution would be relatively trivial...at least on the
guest side.  All the other infrastructure is done and included in the
series I sent out.  The changes to the virtio-net driver on the guest
itself would be minimal.  The bigger effort would be converting
venet-tap to use virtio-ring instead of IOQ.  But this would arguably be
less work than starting a virtio-net backend module from scratch because
you would have to not only code up the entire virtio-net backend, but
also all the pci emulation and irq routing stuff that is required (and
is already done by the vbus infrastructure).  Here all the major pieces
are in place, just the xmit and rx routines need to be converted to
virtio-isms.

For the second option, I agree.  Its probably too nasty and it would be
better if there was just either a virtio-net to kvm-host hack, or a more
pci oriented version of a vbus-like framework.

That said, there is certainly nothing wrong with having an alternate
option.  There is plenty of precedent for having different drivers for
different subsystems, etc, even if there is overlap.  Heck, even KVM has
realtek, e1000, and virtio-net, etc.  Would our kvm community be willing
to work with me to get these patches merged?  I am perfectly willing to
maintain them.  That said, the general infrastructure should probably
not live in -kvm (perhaps -tip, -mm, or -next, etc is more
appropriate).  So a good plan might be to shoot for the core going into
a more general upstream tree.  When/if that happens, then the kvm
community could consider the kvm specific parts, etc.  I realize this is
all pending review acceptance by everyone involved...

-Greg




--------------enig15944E94B338D67A0EF2D94A
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.9 (GNU/Linux)
Comment: Using GnuPG with SUSE - http://enigmail.mozdev.org

iEYEARECAAYFAknUxhkACgkQlOSOBdgZUxnOfACferMtM7V42GsgLSRd6pbmswN5
5nsAni1sbzmd0sK47ROR9zHg0rqBF7Yb
=COVL
-----END PGP SIGNATURE-----

--------------enig15944E94B338D67A0EF2D94A--
