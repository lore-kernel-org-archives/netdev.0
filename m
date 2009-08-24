From: Maximilian Engelhardt <maxi@daemonizer.de>
Subject: Logic for SNAT persistent handling introduced in 2.6.30 is inverted
Date: Mon, 24 Aug 2009 15:16:12 +0200
Message-ID: <200908241516.16544.maxi@daemonizer.de>
Mime-Version: 1.0
Content-Type: multipart/signed;
  boundary="nextPart8693016.B4IW8bsRdp";
  protocol="application/pgp-signature";
  micalg=pgp-sha1
Content-Transfer-Encoding: 7bit
To: "linux-kernel" <linux-kernel@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from daemonizer.de ([87.230.16.230]:49325 "EHLO daemonizer.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752451AbZHXOBZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 24 Aug 2009 10:01:25 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--nextPart8693016.B4IW8bsRdp
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline

Kernel 2.6.30 introduced a patch [1] for the persistent option in the=20
netfilter SNAT target. This is exactly what we need here so I had a quick l=
ook=20
at the code and noticed that the patch is wrong. The logic is simply invert=
ed.
The patch below fixes this.
Also note that because of this the default behavior of the SNAT target has=
=20
changed since kernel 2.6.30 as it now ignores the destination IP in choosin=
g=20
the source IP for nating (which should only be the case if the persistent=20
option is set).

=2D-- net/ipv4/netfilter/nf_nat_core.c.orig       2009-08-24 14:44:00.00000=
0000=20
+0200
+++ net/ipv4/netfilter/nf_nat_core.c    2009-08-24 14:44:43.000000000 +0200
@@ -212,7 +212,7 @@ find_best_ips_proto(struct nf_conntrack_
        maxip =3D ntohl(range->max_ip);
        j =3D jhash_2words((__force u32)tuple->src.u3.ip,
                         range->flags & IP_NAT_RANGE_PERSISTENT ?
=2D                               (__force u32)tuple->dst.u3.ip : 0, 0);
+                               0 : (__force u32)tuple->dst.u3.ip, 0);
        j =3D ((u64)j * (maxip - minip + 1)) >> 32;
        *var_ipp =3D htonl(minip + j);
 }

Signed-off-by: Maximilian Engelhardt <maxi@daemonizer.de>


Greetings,
Maximilian Engelhardt

[1]=20
http://git.eu.kernel.org/?p=3Dlinux/kernel/git/torvalds/linux-2.6.git;a=3Dc=
ommitdiff;h=3D98d500d66cb7940747b424b245fc6a51ecfbf005


--nextPart8693016.B4IW8bsRdp
Content-Type: application/pgp-signature; name=signature.asc 
Content-Description: This is a digitally signed message part.

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.9 (GNU/Linux)

iQIcBAABCgAGBQJKkpKcAAoJEIHqZH0kK9IVvL0QALs8a2z4o9DBhqVX7M+3GcaP
Grt9b9u5c2iypxl1U2KZjfqlCxWtwEzU4WqWlaIo69SsUpA17Ymy657Ib3JQ5Ml0
Gpvt12dvRnpNTLzWQjL79ihUEQ3tlYOT+FBabk+D2df5AlGeu3pnvGmR1V8RlcdW
AGZTswx7/kpn/y1vtYW7FriaA4/WiHJZR3ooYIkTbrWSG0lrHbYHx95dAOs9sSdt
8Sy+cSM0LDY1wARYlC7BIEcY/UnVlQPOuRyPBVelHCdv7Wm+0K5wwGy+yLyF43fF
N53tgpfTA+BhtWIWB6uUQoJS+FumudMBl8G+4Sk4A5rnd0DM2qPud7eyQCNwhehD
287C1ZMDO9N0H7FTx2qc337CIDL1kSMoimmgfhNJxA8SrVToRNH+OjOQuNx3/Esa
ejYGW2jjY6AFG3d/5GAhBmryWpJAjZlaqCtOMOzMD/fMhpJvD26i/xhx0cStDz/a
3JiDfLJ3G4TbE7xEHjS6TVFuh/zzMXz0zRLkvWckOwWo8QNRFoTL+q5m9EAt//Kl
ZC+gTcz5/AoUQaROeuL7SM7CIyhxgXdit9RLG2CZ0I7x+RbPzzYyq5N75TuFec0o
rA/lwia3ed/ENEMNP0wxX8k8ULCuY07fGybg5HHAZhJnXuUiadNibyGMrbMp4if1
vOQuGLMM8+cCdgoQGs/f
=jr5j
-----END PGP SIGNATURE-----

--nextPart8693016.B4IW8bsRdp--
