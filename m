From: Gregory Haskins <ghaskins@novell.com>
Subject: Re: [RFC PATCH v2 00/19] virtual-bus
Date: Thu, 09 Apr 2009 12:48:46 -0400
Message-ID: <49DE26EE.9030402@novell.com>
References: <20090409155200.32740.19358.stgit@dev.haskins.net>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="------------enig107B4FFA0C0392E5505599D7"
Cc: linux-kernel@vger.kernel.org, agraf@suse.de, pmullaney@novell.com,
	pmorreale@novell.com, anthony@codemonkey.ws, rusty@rustcorp.com.au,
	netdev@vger.kernel.org, kvm@vger.kernel.org,
	bhutchings@solarflare.com, andi@firstfloor.org, gregkh@suse.de,
	herber@gondor.apana.org.au, chrisw@sous-sol.org,
	shemminger@vyatta.com
To: avi@redhat.com
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S936514AbZDIQsG@vger.kernel.org>
In-Reply-To: <20090409155200.32740.19358.stgit@dev.haskins.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 2440 and 3156)
--------------enig107B4FFA0C0392E5505599D7
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

Avi,

Gregory Haskins wrote:
>
> Todo:
> *) Develop some kind of hypercall registration mechanism for KVM so tha=
t
>    we can use that as an integration point instead of directly hooking
>    kvm hypercalls
>  =20

What would you like to see here?  I now remember why I removed the
original patch I had for registration...it requires some kind of
discovery mechanism on its own.  Note that this is hard, but I figured
it would make the overall series simpler if I didn't go this route and
instead just integrated with a statically allocated vector.  That being
said, I have no problem adding this back in but figure we should discuss
the approach so I don't go down a rat-hole ;)

So, one thing we could do is use a string-identifier to discover
hypercall resources.  In this model, we would have one additional
hypercall registered with kvm (in addition to the mmu-ops, etc) called
KVM_HC_DYNHC or something like that.  The support for DYNHC could be
indicated in the cpuid (much like I do with the RESET, DYNIRQ, and VBUS
support today.   When hypercall provides register, the could provide a
string such as "vbus", and they would be allocated a hypercall id.=20
Likewise, the HC_DYNHC interface would allow a guest to query the cpuid
for the DYNHC feature, and then query the HC_DYNHC vector for a string
to hc# translation.  If the provider is not present, we return -1 for
the hc#, otherwise we return the one that was allocated.

I know how you feel about string-ids in general, but I am not quite sure
how to design this otherwise without it looking eerily similar to what I
already have (which is registering a new HC vector in kvm_para.h)

Thoughts?

-Greg


--------------enig107B4FFA0C0392E5505599D7
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.9 (GNU/Linux)
Comment: Using GnuPG with SUSE - http://enigmail.mozdev.org

iEYEARECAAYFAkneJu4ACgkQlOSOBdgZUxnKlQCfUC3aBrggFJnxvaRiKGjavnqB
ZHIAmgKAWrK7O20p7s149z/K4vjDMQPt
=laVP
-----END PGP SIGNATURE-----

--------------enig107B4FFA0C0392E5505599D7--
