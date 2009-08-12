From: Gregory Haskins <gregory.haskins@gmail.com>
Subject: AlacrityVM numbers updated for 31-rc4
Date: Wed, 12 Aug 2009 16:43:23 -0400
Message-ID: <4A83296B.3080606@gmail.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="------------enig965E8CB54FAEC0A7B24CCFC8"
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"kvm@vger.kernel.org" <kvm@vger.kernel.org>,
	"Michael S. Tsirkin" <mst@redhat.com>, netdev@vger.kernel.org
To: alacrityvm-devel@lists.sourceforge.net,
	alacrityvm-users@lists.sourceforge.net
Return-path: <kvm-owner@vger.kernel.org>
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 2440 and 3156)
--------------enig965E8CB54FAEC0A7B24CCFC8
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

I re-ran the numbers on 10GE against the actual alacrityvm v0.1 release
available in git on kernel.org.

I tried to include the newly announced "vhost" driver (Michael Tsirkin)
for virtio acceleration, but ran into issues getting the patches to apply=
=2E

For now, this includes native, virtio-u (virtio-userspace), and venet
all running on 31-rc4.  If I can resolve the issue with Michaels
patches, I will add "virtio-k" (virtio-kernel) to the mix as well.  For
now, here are the results for 1500mtu:

native:   7388Mb/s,   29.8us rtt (33505 tps udp-rr)
venet:    3654Mb/s,   56.8us rtt (17600 tps udp-rr)
virtio-u: 1955Mb/s, 4016.0us rtt (  249 tps udp-rr)

Note that on one particular boot-session, I actually saw venet run
consistently 4600Mb/s, and virtio-u run consistently 2800Mb/s.  I am not
sure why other runs resulted in deterministically lower numbers, but I
included the average of the low runs to be conservative, ~3600, ~1900
respectively).

Of interest here is that native made a huge jump (2.6.29 was more like
4Gb/s), and also that KVM regressed a bit, especially compared to native
numbers.  The cause for either of these changes is not known at this
time, but I will investigate the cause over the next few days.

In any case, I have updated the graphs on the AlacrityVM wiki to reflect
these latest numbers:

http://developer.novell.com/wiki/index.php/AlacrityVM

Kind Regards,
-Greg


--------------enig965E8CB54FAEC0A7B24CCFC8
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG/MacGPG2 v2.0.11 (Darwin)
Comment: Using GnuPG with Mozilla - http://enigmail.mozdev.org/

iEYEARECAAYFAkqDKWsACgkQP5K2CMvXmqHOhgCfWd6BYp0Waa95XAhrQf1NqhBm
2EEAnj2/0Fngi3pu7fa3sbRxirTQd/+D
=7ezu
-----END PGP SIGNATURE-----

--------------enig965E8CB54FAEC0A7B24CCFC8--
