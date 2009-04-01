From: Gregory Haskins <ghaskins@novell.com>
Subject: Re: [RFC PATCH 00/17] virtual-bus
Date: Wed, 01 Apr 2009 17:09:02 -0400
Message-ID: <49D3D7EE.4080202@novell.com>
References: <20090331184057.28333.77287.stgit@dev.haskins.net> <87ab71monw.fsf@basil.nowhere.org> <49D35825.3050001@novell.com> <20090401132340.GT11935@one.firstfloor.org> <49D37805.1060301@novell.com> <20090401170103.GU11935@one.firstfloor.org> <49D3B64F.6070703@codemonkey.ws>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="------------enig4A3E9E409F0F02282B3086DE"
Cc: Andi Kleen <andi@firstfloor.org>, linux-kernel@vger.kernel.org,
	agraf@suse.de, pmullaney@novell.com, pmorreale@novell.com,
	rusty@rustcorp.com.au, netdev@vger.kernel.org, kvm@vger.kernel.org
To: Anthony Liguori <anthony@codemonkey.ws>
Return-path: <netdev-owner@vger.kernel.org>
Received: from victor.provo.novell.com ([137.65.250.26]:38671 "EHLO
	victor.provo.novell.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752840AbZDAVGq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Apr 2009 17:06:46 -0400
In-Reply-To: <49D3B64F.6070703@codemonkey.ws>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is an OpenPGP/MIME signed message (RFC 2440 and 3156)
--------------enig4A3E9E409F0F02282B3086DE
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

Anthony Liguori wrote:
> Andi Kleen wrote:
>> On Wed, Apr 01, 2009 at 10:19:49AM -0400, Gregory Haskins wrote:
>> =20
>>>>>            =20
>>>> But surely you must have some specific use case in mind? Something
>>>> that it does better than the various methods that are available
>>>> today. Or rather there must be some problem you're trying
>>>> to solve. I'm just not sure what that problem exactly is.
>>>>        =20
>>> Performance.  We are trying to create a high performance IO
>>> infrastructure.
>>>    =20
>>
>> Ok. So the goal is to bypass user space qemu completely for better
>> performance. Can you please put this into the initial patch
>> description?
>>  =20
>
> FWIW, there's nothing that prevents in-kernel back ends with virtio so
> vbus certainly isn't required for in-kernel backends.

I think there is a slight disconnect here.  This is *exactly* what I am
trying to do.  You can of course do this many ways, and I am not denying
it could be done a different way than the path I have chosen.  One
extreme would be to just slam a virtio-net specific chunk of code
directly into kvm on the host.  Another extreme would be to build a
generic framework into Linux for declaring arbitrary IO types,
integrating it with kvm (as well as other environments such as lguest,
userspace, etc), and building a virtio-net model on top of that.

So in case it is not obvious at this point, I have gone with the latter
approach.  I wanted to make sure it wasn't kvm specific or something
like pci specific so it had the broadest applicability to a range of
environments.  So that is why the design is the way it is.  I understand
that this approach is technically "harder/more-complex" than the "slam
virtio-net into kvm" approach, but I've already done that work.  All we
need to do now is agree on the details ;)

>
>
> That said, I don't think we're bound today by the fact that we're in
> userspace.
You will *always* be bound by the fact that you are in userspace.  Its
purely a question of "how much" and "does anyone care".    Right now,
the anwer is "a lot (roughly 45x slower)" and "at least Greg's customers
do".  I have no doubt that this can and will change/improve in the
future.  But it will always be true that no matter how much userspace
improves, the kernel based solution will always be faster.  Its simple
physics.  I'm cutting out the middleman to ultimately reach the same
destination as the userspace path, so userspace can never be equal.

I agree that the "does anyone care" part of the equation will approach
zero as the latency difference shrinks across some threshold (probably
the single microsecond range), but I will believe that is even possible
when I see it ;)

Regards,
-Greg


--------------enig4A3E9E409F0F02282B3086DE
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.9 (GNU/Linux)
Comment: Using GnuPG with SUSE - http://enigmail.mozdev.org

iEYEARECAAYFAknT1+4ACgkQlOSOBdgZUxkGNwCgibnvQaeK8lgKUD1bjhX0MdhV
lgwAoI8+NEGMILdCm8RahY1sjQlSoDjP
=kRfx
-----END PGP SIGNATURE-----

--------------enig4A3E9E409F0F02282B3086DE--
