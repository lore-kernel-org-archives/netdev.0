From: Gregory Haskins <ghaskins@novell.com>
Subject: Re: [RFC PATCH 00/17] virtual-bus
Date: Wed, 01 Apr 2009 10:42:33 -0400
Message-ID: <49D37D59.2030107@novell.com>
References: <20090331184057.28333.77287.stgit@dev.haskins.net> <87ab71monw.fsf@basil.nowhere.org> <49D35825.3050001@novell.com> <20090401132340.GT11935@one.firstfloor.org> <49D37805.1060301@novell.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="------------enigDBF9BC5F089882EEB16EBB82"
Cc: linux-kernel@vger.kernel.org, agraf@suse.de, pmullaney@novell.com,
	pmorreale@novell.com, anthony@codemonkey.ws, rusty@rustcorp.com.au,
	netdev@vger.kernel.org, kvm@vger.kernel.org,
	linux-rt-users <linux-rt-users@vger.kernel.org>
To: Andi Kleen <andi@firstfloor.org>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S932364AbZDAOkk@vger.kernel.org>
In-Reply-To: <49D37805.1060301@novell.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 2440 and 3156)
--------------enigDBF9BC5F089882EEB16EBB82
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

Gregory Haskins wrote:
> Andi Kleen wrote:
>  =20
>> On Wed, Apr 01, 2009 at 08:03:49AM -0400, Gregory Haskins wrote:
>>  =20
>>    =20
>>> Andi Kleen wrote:
>>>    =20
>>>      =20
>>>> Gregory Haskins <ghaskins@novell.com> writes:
>>>>
>>>> What might be useful is if you could expand a bit more on what the h=
igh level
>>>> use cases for this.=20
>>>>
>>>> Questions that come to mind and that would be good to answer:
>>>>
>>>> This seems to be aimed at having multiple VMs talk
>>>> to each other, but not talk to the rest of the world, correct?=20
>>>> Is that a common use case?=20
>>>>  =20
>>>>      =20
>>>>        =20
>>> Actually we didn't design specifically for either type of environment=
=2E=20
>>>    =20
>>>      =20
>> But surely you must have some specific use case in mind? Something
>> that it does better than the various methods that are available
>> today. Or rather there must be some problem you're trying
>> to solve. I'm just not sure what that problem exactly is.
>>  =20
>>    =20
> Performance.  We are trying to create a high performance IO infrastruct=
ure.
>  =20
Actually, I should also state that I am interested in enabling some new
kinds of features based on having in-kernel devices like this.  For
instance (and this is still very theoretical and half-baked), I would
like to try to support RT guests.

[adding linux-rt-users]

I think one of the things that we need in order to do that is being able
to convey vcpu priority state information to the host in an efficient
way.  I was thinking that a shared-page per vcpu could have something
like "current" and "theshold" priorties.  The guest modifies "current"
while the host modifies "threshold".   The guest would be allowed to
increase its "current" priority without a hypercall (after all, if its
already running presumably it is already of sufficient priority that the
scheduler).  But if the guest wants to drop below "threshold", it needs
to hypercall the host to give it an opportunity to schedule() a new task
(vcpu or not).

The host, on the other hand, could apply a mapping so that the guests
priority of RT1-RT99 might map to RT20-RT30 on the host, or something
like that.  We would have to take other considerations as well, such as
implicit boosting on IRQ injection (e.g. the guest could be in HLT/IDLE
when an interrupt is injected...but by virtue of injecting that
interrupt we may need to boost it to (guest-relative) RT50).

Like I said, this is all half-baked right now.  My primary focus is
improving performance, but I did try to lay the groundwork for taking
things in new directions too..rt being an example.

Hope that helps!
-Greg



--------------enigDBF9BC5F089882EEB16EBB82
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.9 (GNU/Linux)
Comment: Using GnuPG with SUSE - http://enigmail.mozdev.org

iEYEARECAAYFAknTfVkACgkQlOSOBdgZUxkvGgCfcwaE3PyW6wViIAfD1G3/Phpu
0vUAn05ChWnEmKi+YrYgLCSsQiYmUUxD
=CzGJ
-----END PGP SIGNATURE-----

--------------enigDBF9BC5F089882EEB16EBB82--
