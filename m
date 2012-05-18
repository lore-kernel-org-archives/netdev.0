From: Tilman Schmidt <tilman@imap.cc>
Subject: Re: [RFC 13/13] USB: Disable hub-initiated LPM for comms devices.
Date: Sat, 19 May 2012 00:38:41 +0200
Message-ID: <4FB6CF71.7080307@imap.cc>
References: <cover.1337203535.git.sarah.a.sharp@linux.intel.com> <3c634afbbe15598cdcbf77bb9393d22ad4bfa373.1337203535.git.sarah.a.sharp@linux.intel.com> <4FB53054.9070309@imap.cc> <20120517173150.GE4967@xanatos>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="------------enig64FD94716F5B226BF768211C"
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	linux-usb@vger.kernel.org, Alan Stern <stern@rowland.harvard.edu>,
	Hansjoerg Lipp <hjlipp@web.de>,
	linux-bluetooth@vger.kernel.org,
	gigaset307x-common@lists.sourceforge.net, netdev@vger.kernel.org,
	linux-wireless@vger.kernel.org, ath9k-devel@lists.ath9k.org,
	libertas-dev@lists.infradead.org, users@rt2x00.serialmonkey.com
To: Sarah Sharp <sarah.a.sharp@linux.intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out1-smtp.messagingengine.com ([66.111.4.25]:51204 "EHLO
	out1-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755125Ab2ERWiq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 May 2012 18:38:46 -0400
In-Reply-To: <20120517173150.GE4967@xanatos>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is an OpenPGP/MIME signed message (RFC 2440 and 3156)
--------------enig64FD94716F5B226BF768211C
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

Am 17.05.2012 19:31, schrieb Sarah Sharp:
> On Thu, May 17, 2012 at 07:07:32PM +0200, Tilman Schmidt wrote:
>>
>> I follow the argument for class drivers. But this patch also
>> modifies drivers for specific existing USB 2.0 only devices
>> which are unlikely to ever grow USB 3.0 support, such as the
>> Gigaset ISDN driver:
>>
>>>  drivers/isdn/gigaset/bas-gigaset.c            |    1 +
>>>  drivers/isdn/gigaset/usb-gigaset.c            |    1 +
>=20
> Is there a particular reason why you think that driver is unlikely to
> ever get USB 3.0 support?

Actually, there is. :-)
- The USB devices driven by this driver aren't built anymore.
- Their USB interface design is quite, um, idiosyncratic, and it's
  pretty unlikely that anyone will reuse it. (At least I truly hope
  no one will.)
- Their successor models have completely different and incompatible
  USB interfaces which this driver is unable to handle.

>> What is the interest of setting the disable_hub_initiated_lpm
>> flag for these?
>=20
> It's partially to lay the foundation for anyone who wants to make a USB=

> 3.0 communications driver in the future.  They're likely to start from
> some USB 2.0 class driver, and copy a lot of code.  If they notice that=

> flag is set in all the USB communications class drivers, they're likely=

> to set it as well.

You've got a point there.

> I'm not quite sure where the best place to provide documentation on the=

> flag is.  I've added the kernel doc comments to the structure, but mayb=
e
> it needs to be documented somewhere in Documentation/usb/?

Documentation/usb/power-management.txt would seem like a natural
place. Although it appears to limit itself to "suspending" in its
first paragraph, it does have a section "xHCI hardware link PM"
at the end already, added by Andiry Xu on 2011-09-23.

Hmmm, that section seems to suggest that LPM exists for USB2, too.
Perhaps I should reconsider my attitude towards your patch.

Thanks,
Tilman

--=20
Tilman Schmidt                    E-Mail: tilman@imap.cc
Bonn, Germany
Diese Nachricht besteht zu 100% aus wiederverwerteten Bits.
Unge=F6ffnet mindestens haltbar bis: (siehe R=FCckseite)


--------------enig64FD94716F5B226BF768211C
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.16 (GNU/Linux)
Comment: Using GnuPG with Mozilla - http://enigmail.mozdev.org/

iEYEARECAAYFAk+2z3IACgkQQ3+did9BuFs/RgCfdQ3ASobaleTQ6niqoTvKtb/g
1x8AnRvNqVATSpi6N3gcSrgLEfrQUtrn
=QHD+
-----END PGP SIGNATURE-----

--------------enig64FD94716F5B226BF768211C--
