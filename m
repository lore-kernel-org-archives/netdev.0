From: Gregory Haskins <ghaskins@novell.com>
Subject: Re: [RFC PATCH 00/17] virtual-bus
Date: Fri, 03 Apr 2009 07:28:58 -0400
Message-ID: <49D5F2FA.9040107@novell.com>
References: <20090402085253.GA29932@gondor.apana.org.au> <49D47F11.6070400@redhat.com> <49D5EBE1.8030200@redhat.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="------------enig3648B391CE68DF47139AF7E9"
Cc: Avi Kivity <avi@redhat.com>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	anthony@codemonkey.ws, andi@firstfloor.org,
	linux-kernel@vger.kernel.org, agraf@suse.de, pmullaney@novell.com,
	pmorreale@novell.com, rusty@rustcorp.com.au,
	netdev@vger.kernel.org, kvm@vger.kernel.org
To: Gerd Hoffmann <kraxel@redhat.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1763901AbZDCL1P@vger.kernel.org>
In-Reply-To: <49D5EBE1.8030200@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 2440 and 3156)
--------------enig3648B391CE68DF47139AF7E9
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

Gerd Hoffmann wrote:
> Avi Kivity wrote:
>  =20
>> There is no choice.  Exiting from the guest to the kernel to userspace=

>> is prohibitively expensive, you can't do that on every packet.
>>    =20
>
> I didn't look at virtio-net very closely yet.  I wonder why the
> notification is that a big issue though.  It is easy to keep the number=

> of notifications low without increasing latency:
>
> Check shared ring status when stuffing a request.  If there are request=
s
> not (yet) consumed by the other end there is no need to send a
> notification.  That scheme can even span multiple rings (nics with rx
> and tx for example).
>  =20

FWIW: I employ this scheme.  The shm-signal construct has a "dirty" and
"pending" flag (all on the same cacheline, which may or may not address
Andi's later point).  The first time you dirty the shm, it sets both
flags.  The consumer side has to clear "pending" before any subsequent
signals are sent.  Normally the consumer side will also clear "enabled"
(as part of the bidir napi thing) to further disable signals.

-Greg




--------------enig3648B391CE68DF47139AF7E9
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.9 (GNU/Linux)
Comment: Using GnuPG with SUSE - http://enigmail.mozdev.org

iEYEARECAAYFAknV8voACgkQlOSOBdgZUxkKHwCeNvxwcuTz9HTrbrUTS4gWQa9P
nHQAn2/rDyJr/HRmdxYJC9url+izu/lI
=gaNi
-----END PGP SIGNATURE-----

--------------enig3648B391CE68DF47139AF7E9--
