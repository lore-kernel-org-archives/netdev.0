From: Pierre Ossman <drzeus-list@drzeus.cx>
Subject: accelerated vlan gives pcap tagged packets untagged
Date: Sun, 8 Feb 2009 12:37:35 +0100
Message-ID: <20090208123735.15d9ea4b@mjolnir.drzeus.cx>
Mime-Version: 1.0
Content-Type: multipart/signed; protocol="application/pgp-signature"; micalg=PGP-SHA1; boundary="=_freyr.drzeus.cx-31755-1234093061-0001-2"
To: Francois Romieu <romieu@fr.zoreil.com>, netdev@vger.kernel.org,
	Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 82-117-125-11.tcdsl.calypso.net ([82.117.125.11]:46737 "EHLO
	smtp.drzeus.cx" rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751341AbZBHLhp (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 8 Feb 2009 06:37:45 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a MIME-formatted message.  If you see this text it means that your
E-mail software does not support MIME-formatted messages.

--=_freyr.drzeus.cx-31755-1234093061-0001-2
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

Hi,

I'm having some problems with r8169 and vlans. The basic problem is
that pcap on eth1 gives me tagged packets, but in a form where it is
impossible to tell it is tagged. This is causing problems for dhcpd:

Feb  6 20:04:22 asgard dhcpd: DHCPDISCOVER from 00:15:00:08:98:1f via eth1.2
Feb  6 20:04:22 asgard dhcpd: DHCPDISCOVER from 00:15:00:08:98:1f via eth1
Feb  6 20:04:23 asgard dhcpd: DHCPOFFER on 10.8.2.230 to 00:15:00:08:98:1f =
via eth1.2
Feb  6 20:04:23 asgard dhcpd: DHCPOFFER on 10.8.0.128 to 00:15:00:08:98:1f =
via eth1
Feb  6 20:04:23 asgard dhcpd: DHCPREQUEST for 10.8.2.230 (10.8.2.254) from =
00:15:00:08:98:1f via eth1.2
Feb  6 20:04:23 asgard dhcpd: DHCPACK on 10.8.2.230 to 00:15:00:08:98:1f vi=
a eth1.2
Feb  6 20:04:23 asgard dhcpd: DHCPREQUEST for 10.8.2.230 (10.8.2.254) from =
00:15:00:08:98:1f via eth1: wrong network.
Feb  6 20:04:23 asgard dhcpd: DHCPNAK on 10.8.2.230 to 00:15:00:08:98:1f vi=
a eth1

I assume this is because the hardware supports vlans and handles all
the tag stripping.

(I've confirmed with tcpdump that the packets lack tags when they are
presented to userspace)

=46rom what I can tell, I cannot fix this without rebuilding the kernel
and removing the acceleration support from the r8169 driver. Is there
some method I've overlooked?

Preferably, I'd like the kernel to expose to pcap what's on the wire
(i.e. accelerated vs non-accelerated looks the same from userspace). If
that means too much processing to be desirable, the next best thing
would be to simply not show tagged packets on the raw interface. The
ability to turn vlan acceleration on and off in the latter case would
also be desirable for network debugging.


Possibly related, all docs state that header reordering is disabled by
default. But it is on by default here. This might be because of the
acceleration, but the docs need some type of update either way. :)

Thanks
--=20
     -- Pierre Ossman

  Linux kernel, MMC maintainer        http://www.kernel.org
  rdesktop, core developer          http://www.rdesktop.org

  WARNING: This correspondence is being monitored by the
  Swedish government. Make sure your server uses encryption
  for SMTP traffic and consider using PGP for end-to-end
  encryption.

--=_freyr.drzeus.cx-31755-1234093061-0001-2
Content-Type: application/pgp-signature; name="signature.asc"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment; filename=signature.asc

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.9 (GNU/Linux)

iEYEARECAAYFAkmOxAMACgkQ7b8eESbyJLhOkACgxWfjGbQI1coBaIhEz1kvTeZM
Y2EAoMqbKNcMPzLwMeNMH5sMrWxsDW1k
=Czcv
-----END PGP SIGNATURE-----

--=_freyr.drzeus.cx-31755-1234093061-0001-2--
