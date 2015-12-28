From: Doug Ledford <dledford@redhat.com>
Subject: 4.4-rc7 failure report
Date: Mon, 28 Dec 2015 16:53:45 -0500
Message-ID: <5681AF69.4040204@redhat.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
 protocol="application/pgp-signature";
 boundary="uIgT6Qm5ouFdK7hCQPA14VFtcdEApEDUR"
To: David Miller <davem@davemloft.net>,
	David Miller <davem@redhat.com>,
	netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:37849 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752887AbbL1Vxr (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 28 Dec 2015 16:53:47 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--uIgT6Qm5ouFdK7hCQPA14VFtcdEApEDUR
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable

Hi Dave,

The 4.4-rc7 kernel is failing for me.  In my case, all of my vlan
interfaces are failing to obtain a dhcp address using dhclient.  I've
tried a hand built 4.4-rc7, and the Fedora rawhide 4.4-rc7 kernel, both
failed.  I've tried NetworkManager and the old SysV network service,
both fail.  I tried a working dhclient from rhel7 on the Fedora rawhide
install and it failed too.  Running tcpdump on the interface shows the
dhcp request going out, and a dhcp response coming back in.  Running
strace on dhclient shows that it writes the dhcp request, but it never
recvs a dhcp response.  If I manually bring the interface up with a
static IP address then I'm able to run typical IP traffic across the
link (aka, ping).  It would seem that when dhclient registers a packet
filter on the socket, that filter is preventing it from ever getting the
dhcp response.  The same dhclient works on any non-vlan interfaces in
the system, so the filter must work for non-vlan interfaces.  Aside from
the fact that the interface is a vlan, we also use a priority egress map
on the interface, and we use PFC flow control.  Let me know if you need
anymore to debug the issue, or email me off list and I can get you
logins to my reproducer machines.

--=20
Doug Ledford <dledford@redhat.com>
              GPG KeyID: 0E572FDD



--uIgT6Qm5ouFdK7hCQPA14VFtcdEApEDUR
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2
Comment: Using GnuPG with Thunderbird - http://www.enigmail.net/

iQIcBAEBCAAGBQJWga9pAAoJELgmozMOVy/dAkwQAIo0pVotrm56cG8L9ZQnFO93
iu91kj5z8zEBnj3iAsantKZFUJjUzMKbgtlUUcGCDl3L4zLTkS8IPiJMhqb8/Qhu
HF0iIP7fnA1VTt+O/TJLi04Zk1OV9cNWWjxTu+rgZ9mB7jkntWNh/wkFIpCPYnxZ
Fru0xzUSbyPjqsCACJO+MHpuKqTmXcIRzeYZsdKwXpf/bHpMsqSWZJQu0gveHWUb
D6jSHTmg1Vg9X9aEX02s5s1ZQc/nb6HJEqq4nfMX+UXjr98UPKtLkmn6N/W/G7y2
NbzGNJXEzlZZN5jldr0+mqlMCJrvvVAy7QVImd9xJHRLmSF0nYEGRIwwrEslmL9x
8iyFPG3JUOuEVe5g1GysF0syshNG2Qc8sc5e4HbaqkNhhddjCQ4V+0bcixpNonuG
vFVGJ8xR94S2/7PwWGG37v00tDkTjcsB0Bexyb7ZNYVTQPba5Vt2feAd7Z/eoJO2
BbVVhr3vtz845tp6BUoq+tTMX8NKGv8AhYaxxga+1z/tJeUgHG8+5jm8e7wSCg7p
bSyr7Bzgv8UhEhZaca8APdbOqEKHJcUBCOe/9cJQH5gmEY6No7PsBt31B16Yj51O
1rjUtMDmL06ETqzDxxM1Q9LHX+kZmMsYGY+AE+SABcFdOlog1Fzc03iU9eNJZhjv
sfejXhVHA6jX40C/PF05
=aVjq
-----END PGP SIGNATURE-----

--uIgT6Qm5ouFdK7hCQPA14VFtcdEApEDUR--
