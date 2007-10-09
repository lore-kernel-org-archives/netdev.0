From: Anton Arapov <aarapov@redhat.com>
Subject: [PATCH] ipv4: kernel panic when only one unsecured port available
Date: Tue, 09 Oct 2007 16:01:55 +0200
Message-ID: <m3bqb89yjw.fsf@bandura.englab.brq.redhat.com>
Mime-Version: 1.0
Content-Type: multipart/signed; boundary="=-=-=";
	micalg=pgp-sha1; protocol="application/pgp-signature"
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:45644 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752933AbXJIOCH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 9 Oct 2007 10:02:07 -0400
Received: from int-mx1.corp.redhat.com (int-mx1.corp.redhat.com [172.16.52.254])
	by mx1.redhat.com (8.13.8/8.13.1) with ESMTP id l99E24Oe022158
	for <netdev@vger.kernel.org>; Tue, 9 Oct 2007 10:02:04 -0400
Received: from pobox.stuttgart.redhat.com (pobox.stuttgart.redhat.com [172.16.2.10])
	by int-mx1.corp.redhat.com (8.13.1/8.13.1) with ESMTP id l99E23dK028686
	for <netdev@vger.kernel.org>; Tue, 9 Oct 2007 10:02:03 -0400
Received: from bandura.englab.brq.redhat.com (bandura.englab.brq.redhat.com [10.34.32.159])
	by pobox.stuttgart.redhat.com (8.12.11.20060308/8.12.11) with ESMTP id l99E22HO004431
	for <netdev@vger.kernel.org>; Tue, 9 Oct 2007 16:02:02 +0200
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--=-=-=
Content-Transfer-Encoding: quoted-printable

Steps to reproduce:
Server:
  [root@server ~]# cat /etc/exports
  /export *(ro,insecure)
// there is insecure ... I am using ports like "1024 to 61000"
  [root@server ~] service nfs restart=20

Client:
  1.[root@client ~]# echo 32768 32768 > /proc/sys/net/ipv4/ip_local_port_ra=
nge
  32768   32768
// two same numbers, for ex "32769 32769" etc.
  2.[root@client ~]# cat /proc/sys/net/ipv4/ip_local_port_range
  32768   32768
  3.[root@client ~]# mount server:/export /import
=20=20
Actual results:
  Kernel always panics=20

=2D-------------------------------------------------------------------
[PATCH] ipv4: kernel panic when only one unsecured port available

  Patch prevents division by zero. Kernel panics if only one=20
unsecured port available.

Signed-off-by: Anton Arapov <aarapov@redhat.com>
=2D--

 net/ipv4/inet_connection_sock.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/ipv4/inet_connection_sock.c b/net/ipv4/inet_connection_soc=
k.c
index fbe7714..00ad079 100644
=2D-- a/net/ipv4/inet_connection_sock.c
+++ b/net/ipv4/inet_connection_sock.c
@@ -80,7 +80,7 @@ int inet_csk_get_port(struct inet_hashinfo *hashinfo,
 		int low =3D sysctl_local_port_range[0];
 		int high =3D sysctl_local_port_range[1];
 		int remaining =3D (high - low) + 1;
=2D		int rover =3D net_random() % (high - low) + low;
+		int rover =3D net_random() % remaining + low;
=20
 		do {
 			head =3D &hashinfo->bhash[inet_bhashfn(rover, hashinfo->bhash_size)];

=2D-=20
Anton Arapov, <aarapov@redhat.com>
Kernel Development, Red Hat
GPG Key ID: 0x6FA8C812

--=-=-=
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.5 (GNU/Linux)

iD8DBQFHC4naVub9yW+oyBIRAoR1AJ0XZSFUptYVWvRwEHYTUCyj2M6RmQCg0JWE
KqivLr9gsnVQc3YoalxRtP0=
=KUuB
-----END PGP SIGNATURE-----
--=-=-=--
