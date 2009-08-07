From: Gregory Haskins <gregory.haskins@gmail.com>
Subject: Re: [PATCH 0/7] AlacrityVM guest drivers
Date: Fri, 07 Aug 2009 11:05:44 -0400
Message-ID: <4A7C42C8.5050608@gmail.com>
References: <20090803171030.17268.26962.stgit@dev.haskins.net> <20090806081955.GA9752@redhat.com> <4A7C37E5.4040302@codemonkey.ws>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="------------enigDD6D7DE8A19889E7EA51257E"
Cc: "Michael S. Tsirkin" <mst@redhat.com>,
	Gregory Haskins <ghaskins@novell.com>,
	linux-kernel@vger.kernel.org,
	alacrityvm-devel@lists.sourceforge.net, netdev@vger.kernel.org,
	kvm@vger.kernel.org
To: Anthony Liguori <anthony@codemonkey.ws>
Return-path: <kvm-owner@vger.kernel.org>
In-Reply-To: <4A7C37E5.4040302@codemonkey.ws>
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 2440 and 3156)
--------------enigDD6D7DE8A19889E7EA51257E
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

Anthony Liguori wrote:
> Michael S. Tsirkin wrote:
>>
>>> This series includes the basic plumbing, as well as the driver for
>>> accelerated 802.x (ethernet) networking.
>>>    =20
>>
>> The graphs comparing virtio with vbus look interesting.
>>  =20
>=20
> 1gbit throughput on a 10gbit link?  I have a hard time believing that.
>=20
> I've seen much higher myself.  Can you describe your test setup in more=

> detail?

Sure,

For those graphs, two 8-core x86_64 boxes with Chelsio T3 10GE connected
back to back via cross over with 1500mtu.  The kernel version was as
posted.  The qemu version was generally something very close to
qemu-kvm.git HEAD at the time the data was gathered, but unfortunately I
didn't seem to log this info.

For KVM, we take one of those boxes and run a bridge+tap configuration
on top of that.  We always run the server on the bare-metal machine on
the remote side of the link regardless of whether we run the client in a
VM or baremetal.

For guests, virtio-net and venet connect to the same linux bridge
instance, I just "ifdown eth0 / ifup eth1" (or vice versa) and repeat
the same test.  I do this multiple times (usually about 10) and average
the result.  I use several different programs, such as netperf, rsync,
and ping to take measurements.

That said, note that the graphs were from earlier kernel runs (2.6.28,
29-rc8).  The most recent data I can find that I published is for
2.6.29, announced with the vbus-v3 release back in April:

http://lkml.org/lkml/2009/4/21/408

In it, the virtio-net throughput numbers are substantially higher and
possibly more in line with your expectations (4.5gb/s) (though notably
still lagging venet, which weighed in at 5.6gb/s).

Generally, I find that the virtio-net exhibits non-deterministic results
from release to release.  I suspect (as we have discussed) the
tx-mitigation scheme.  Some releases buffer the daylights out of the
stream, and virtio gets close(r) throughput (e.g. 4.5g vs 5.8g, but
absolutely terrible latency (4000us vs 65us).  Other releases it seems
to operate with more of a compromise (1.3gb/s vs 3.8gb/s, but 350us vs
85us).

I do not understand what causes the virtio performance fluctuation, as I
use the same kernel config across builds, and I do not typically change
the qemu userspace.  Note that some general fluctuation is evident
across the board just from kernel to kernel.  I am referring to more of
the disparity in throughput vs latency than the ultimate numbers, as all
targets seem to scale max throughput about the same per kernel.

That said, I know I need to redo the graphs against HEAD (31-rc5, and
perhaps 30, and kvm.git).  I've been heads down with the eventfd
interfaces since vbus-v3 so I havent been as active with generating the
results. I did confirm that vbus-v4 (alacrityvm-v0.1) still produces a
similar graph, but I didn't gather the data as scientifically as I would
feel comfortable publishing a graph for.  This is on the TODO list.

If there is another patch-series/tree I should be using for comparison,
please point me at it.

HTH

Kind Regards,
-Greg


--------------enigDD6D7DE8A19889E7EA51257E
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG/MacGPG2 v2.0.11 (Darwin)
Comment: Using GnuPG with Mozilla - http://enigmail.mozdev.org/

iEYEARECAAYFAkp8QsgACgkQP5K2CMvXmqFUDgCcCtEq2PSKDkISw0/H2jQTDhKG
3PMAnjSZ7zETv4xR52xzlNJVAZOojVrI
=QpOe
-----END PGP SIGNATURE-----

--------------enigDD6D7DE8A19889E7EA51257E--
