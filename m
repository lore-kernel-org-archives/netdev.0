From: Gregory Haskins <ghaskins@novell.com>
Subject: Re: [RFC PATCH v2 03/19] vbus: add connection-client helper infrastructure
Date: Thu, 04 Jun 2009 14:30:59 -0400
Message-ID: <4A2812E3.6090108@novell.com>
References: <20090409155200.32740.19358.stgit@dev.haskins.net> <20090409163057.32740.27829.stgit@dev.haskins.net> <20090604180611.GA16387@redhat.com> <4A280FE2.2090101@novell.com> <4A281161.8010109@redhat.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="------------enigB0D4C7096C08A012074AC706"
Cc: "Michael S. Tsirkin" <mst@redhat.com>,
	linux-kernel@vger.kernel.org, agraf@suse.de, pmullaney@novell.com,
	pmorreale@novell.com, anthony@codemonkey.ws, rusty@rustcorp.com.au,
	netdev@vger.kernel.org, kvm@vger.kernel.org,
	bhutchings@solarflare.com, andi@firstfloor.org, gregkh@suse.de,
	herber@gondor.apana.org.au, chrisw@sous-sol.org,
	shemminger@vyatta.com
To: Avi Kivity <avi@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from victor.provo.novell.com ([137.65.250.26]:34308 "EHLO
	victor.provo.novell.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751327AbZFDSbT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Jun 2009 14:31:19 -0400
In-Reply-To: <4A281161.8010109@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is an OpenPGP/MIME signed message (RFC 2440 and 3156)
--------------enigB0D4C7096C08A012074AC706
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

Avi Kivity wrote:
> Gregory Haskins wrote:
>
>  =20
>>> BTW, why did you decide to use get_user_pages?
>>> Would switch_mm + copy_to_user work as well
>>> avoiding page walk if all pages are present?
>>>      =20
>>
>> Well, basic c_t_u() won't work because its likely not "current" if you=

>> are updating the ring from some other task, but I think you have alrea=
dy
>> figured that out based on the switch_mm suggestion.  The simple truth =
is
>> I was not familiar with switch_mm at the time I wrote this (nor am I
>> now).  If this is a superior method that allows you to acquire
>> c_t_u(some_other_ctx) like behavior, I see no problem in changing.  I
>> will look into this, and thanks for the suggestion!
>>  =20
>
> copy_to_user() is significantly faster than get_user_pages() + kmap()
> + memcmp() (or their variants).
>

Oh, I don't doubt that (in fact, I was pretty sure that was the case
based on some of the optimizations I could see in studying the c_t_u()
path).  I just didn't realize there were other ways to do it if its a
non "current" task. ;)

I guess the enigma for me right now is what cost does switch_mm have?=20
(Thats not a slam against the suggested approach...I really do not know
and am curious).

As an aside, note that we seem to be reviewing v2, where v3 is really
the last set I pushed.  I think this patch is more or less the same
across both iterations, but FYI that I would recommend looking at v3
instead.

-Greg


--------------enigB0D4C7096C08A012074AC706
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG/MacGPG2 v2.0.11 (Darwin)
Comment: Using GnuPG with Mozilla - http://enigmail.mozdev.org

iEYEARECAAYFAkooEuYACgkQlOSOBdgZUxkmfgCeJqaWFdY127W4daE380kxoXPK
BRcAnjZzRdKA19iXdzdlnEnucN9PQv0T
=i/rM
-----END PGP SIGNATURE-----

--------------enigB0D4C7096C08A012074AC706--
