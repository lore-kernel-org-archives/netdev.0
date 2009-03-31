From: Gregory Haskins <ghaskins@novell.com>
Subject: Re: [RFC PATCH 14/17] kvm: add a reset capability
Date: Tue, 31 Mar 2009 16:37:56 -0400
Message-ID: <49D27F24.1070709@novell.com>
References: <20090331184057.28333.77287.stgit@dev.haskins.net> <20090331184400.28333.50396.stgit@dev.haskins.net> <49D26D8B.7020201@redhat.com> <49D276E5.6000000@novell.com> <49D27A9B.9030703@redhat.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="------------enig7F02F679749E998113F6CED3"
Cc: linux-kernel@vger.kernel.org, agraf@suse.de, pmullaney@novell.com,
	pmorreale@novell.com, anthony@codemonkey.ws, rusty@rustcorp.com.au,
	netdev@vger.kernel.org, kvm@vger.kernel.org
To: Avi Kivity <avi@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from victor.provo.novell.com ([137.65.250.26]:45455 "EHLO
	victor.provo.novell.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754046AbZCaUfl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 31 Mar 2009 16:35:41 -0400
In-Reply-To: <49D27A9B.9030703@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is an OpenPGP/MIME signed message (RFC 2440 and 3156)
--------------enig7F02F679749E998113F6CED3
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

Avi Kivity wrote:
> Gregory Haskins wrote:
>> Avi Kivity wrote:
>> =20
>>> Gregory Haskins wrote:
>>>   =20
>>>> We need a way to detect if a VM is reset later in the series, so let=
s
>>>> add a capability for userspace to signal a VM reset down to the
>>>> kernel.
>>>>        =20
>>> How do you handle the case of a guest calling kexec to load a new
>>> kernel?  Or is that not important for your use case?
>>>
>>>    =20
>>
>> Hmm..I had not considered this.  Any suggestions on ways to detect it?=

>>
>>  =20
>
> Best would be not to detect it; it's tying global events into a
> device.  Instead, have a reset command for your device and have the
> driver issue it on load and unload.

Yes, good point.  This is doable within the existing infrastructure, but
it would have to be declared in each devices ABI definition.  I could
make it more formal and add it to the list of low-level bus-verbs, like
DEVICEOPEN, DEVICECLOSE, etc.

>
> btw, reset itself would be better controlled from userspace; qemu
> knows about resets and can reset vbus devices directly instead of
> relying on kvm to reset them.
In a way, this is what I have done (note to self: post the userspace
patches)

The detection is done by userspace, and it invokes an ioctl.  The kernel
based devices then react if they are interested.  In my case, vbus
registers for reset-notification, and it acts as if the guest exited
when it gets reset (e.g. it issues DEVICECLOSE verbs to all devices the
guest had open).



--------------enig7F02F679749E998113F6CED3
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.9 (GNU/Linux)
Comment: Using GnuPG with SUSE - http://enigmail.mozdev.org

iEYEARECAAYFAknSfyQACgkQlOSOBdgZUxnmJQCfRd0OJOxHMirir8PbPlPPwa5G
ZbMAn1JbH3kE+3CzUbETZSS84q6m6YiO
=sf6d
-----END PGP SIGNATURE-----

--------------enig7F02F679749E998113F6CED3--
