From: David Lamparter <equinox@diac24.net>
Subject: Re: kernel bug 14839
Date: Fri, 17 Dec 2010 16:31:31 +0100
Message-ID: <20101217153131.GD2164726@jupiter.n2.diac24.net>
References: <588003.11315.qm@web113905.mail.gq1.yahoo.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="hYooF8G/hrfVAmum"
Cc: netdev@vger.kernel.org
To: Ian Shorter <mcisho@yahoo.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from spaceboyz.net ([87.106.131.203]:41681 "EHLO spaceboyz.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752087Ab0LQPbh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 17 Dec 2010 10:31:37 -0500
Content-Disposition: inline
In-Reply-To: <588003.11315.qm@web113905.mail.gq1.yahoo.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--hYooF8G/hrfVAmum
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Fri, Dec 17, 2010 at 07:18:58AM -0800, Ian Shorter wrote:
> At the end of 2009 I reported kernel bug 14839: "Trying to use a TUN
> device for IPv6 traffic, cannot set destination address". I was
> wondering whether any progress has been made towards resolving the
> problem? Regards.

The bug is invalid. You are incorrectly assuming the IPv4 pattern of a
"local" and a "remote" address applies to IPv6. Also, you are
incorrectly using an fe80:: address with a /128 mask. (fe80:: with
anything but /64 is usually gross mis-setup)

Please change the application to do the following:
* add a fe80::/64 address to the tun device
* use either device-only routes ("2001:db8::/32 dev tun0") or get the
  peer link-local address (might be complicated) and use that as
  nexthop.

-David


--hYooF8G/hrfVAmum
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.16 (GNU/Linux)

iEYEARECAAYFAk0LglMACgkQpfBGV6DCGYZBlACgg18Mb1dwxtrxgy60nOy3/2kJ
ijYAn0Qm16kJDeRvaqm9UdUCuhb5fvqI
=H2+G
-----END PGP SIGNATURE-----

--hYooF8G/hrfVAmum--
