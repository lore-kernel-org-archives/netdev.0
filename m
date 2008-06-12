From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: 2.6.25rc7 lockdep trace
Date: Thu, 12 Jun 2008 09:20:34 +0200
Message-ID: <1213255234.3871.3.camel@johannes.berg>
References: <20080403.134813.201577998.davem@davemloft.net>
	 <1207320492.19189.33.camel@johannes.berg>
	 <20080610.224023.116817726.davem@davemloft.net>
	 <20080611.224639.250054768.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-C0h5VkpFxdqEA8b4k0US"
Cc: davej@codemonkey.org.uk, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from xc.sipsolutions.net ([83.246.72.84]:43173 "EHLO
	sipsolutions.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750879AbYFLHVZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Jun 2008 03:21:25 -0400
In-Reply-To: <20080611.224639.250054768.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-C0h5VkpFxdqEA8b4k0US
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

Technically,

> If the RTNL is held when we invoke flush_scheduled_work() we could
> deadlock.  One such case is linkwatch, it is a workqueue which tries
                                            that ^^^^^^^^^

> The most common case are net driver ->stop() methods.  The
> simplest conversion is to instead use cancel_{delayed_}work_sync()
> explicitly on the various workqueues the driver uses.
                   and that ^^^^^^^^^^

> This is an OK transformation because these workqueues are doing things
                                    and that ^^^^^^^^^^

should read "work struct" because it all uses the global workqueue.

I haven't looked at the drivers in more detail (sorry) but the patch
itself looks fine to me (but I wouldn't have caught something like Jarek
did with the now-unused variables.)

johannes

--=-C0h5VkpFxdqEA8b4k0US
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Comment: Johannes Berg (powerbook)

iQIcBAABAgAGBQJIUM49AAoJEKVg1VMiehFYY4kP/jAx+jx7xKTbQXkGXw+zweaW
qo4j41q/oaN1JnV++jyllOZhbWQEKxi7KLhxLT4+Y+YYR+U3W7TsVQIg67NspATX
yYCIje2L6wXwOeHBhajOMuxoZK8xK5FwyJqKgWOM2XnqOeeX9Z1dgzXb1oDj+SGx
JF3V8OCo3AkXMUFVEiLTOdNkQqwYkeJ/f9dkaASkDcJG2Ws40oe8pTKkFh1Evoua
W+DVd0a4JfOEaY2MZ8tc33V2d/Ye6fLaT1qS3XDavouXPyXWUnLDoGc3knc53vR1
Mi1CbweY6UNSRD4FlM6+kcFSup6n8yepGDPp+G/iTHY3o4D9Ok9FsMgB0Ub4rNEJ
kIMjer7RXYXHvwZmR1gnRCE8e92QM4zLsDuueqHzG3lqNOFarLGmUS/kZ4ZezNCT
TRky1MFAaIESoXJxsL+RtixOEdJeIwo7BNDQOcD1jb5WAl61ruIF0zznwrRialgB
b4mJ5HwiQWD6bz6MZMi4gSYul2rOdt/2xpNlXV45pO5ZyTtwXnU3mxGZ5vpT2/DL
CDgSeJA/wF9D5gnJGkH6brkbAf+shrCh0PlI0TOzCan66GH9xwgiOrfq48tPH9Gw
21E46PYsEp6XQr1aDckOMvF2SvdlIBgJQIkt1EWr71Y9b3igvxFBcFmt1A6xcOh5
a6iRMmcrnktx2OsAnRZw
=6pGn
-----END PGP SIGNATURE-----

--=-C0h5VkpFxdqEA8b4k0US--

