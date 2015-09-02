From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [Intel-wired-lan] [PATCH] ixgbe: Limit lowest interrupt rate
 for adaptive interrupt moderation to 12K
Date: Wed, 02 Sep 2015 03:07:00 -0700
Message-ID: <1441188420.2783.18.camel@intel.com>
References: <20150730221927.984.91700.stgit@ahduyck-vm-fedora22>
	 <55E655A3.9010304@gmail.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-/XbFWbB5648Sx9Fe4HLT"
Cc: Alexander Duyck <alexander.h.duyck@redhat.com>,
	netdev@vger.kernel.org, intel-wired-lan@lists.osuosl.org
To: Alexander Duyck <alexander.duyck@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([134.134.136.65]:37600 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751589AbbIBKHD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 2 Sep 2015 06:07:03 -0400
In-Reply-To: <55E655A3.9010304@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-/XbFWbB5648Sx9Fe4HLT
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Tue, 2015-09-01 at 18:49 -0700, Alexander Duyck wrote:
> On 07/30/2015 03:19 PM, Alexander Duyck wrote:
> > This patch updates the lowest limit for adaptive interrupt interrupt
> > moderation to roughly 12K interrupts per second.
> >
> > The way I came about reaching 12K as the desired interrupt rate is
> by
> > testing with UDP flows.  Specifically I had a simple test that ran a
> > netperf UDP_STREAM test at varying sizes.  What I found was as the
> packet
> > sizes increased the performance fell steadily behind until we were
> only
> > able to receive at ~4Gb/s with a message size of 65507.  A bit of
> digging
> > found that we were dropping packets for the socket in the network
> stack,
> > and looking at things further what I found was I could solve it by
> increasing
> > the interrupt rate, or increasing the rmem_default/rmem_max.  What I
> found was
> > that when the interrupt coalescing resulted in more data being
> processed
> > per interrupt than could be stored in the socket buffer we started
> losing
> > packets and the performance dropped.  So I reached 12K based on the
> > following math.
> >
> > rmem_default =3D 212992
> > skb->truesize =3D 2994
> > 212992 / 2994 =3D 71.14 packets to fill the buffer
> >
> > packet rate at 1514 packet size is 812744pps
> > 71.14 / 812744 =3D 87.9us to fill socket buffer
> >
> > >From there it was just a matter of choosing the interrupt rate and
> > providing a bit of wiggle room which is why I decided to go with 12K
> > interrupts per second as that uses a value of 84us.
> >
> > The data below is based on VM to VM over a direct assigned ixgbe
> interface.
> > The test run was:
> >       netperf -H <ip> -t UDP_STREAM"
> >
> > Socket  Message  Elapsed      Messages                   CPU
> Service
> > Size    Size     Time         Okay Errors   Throughput   Util
> Demand
> > bytes   bytes    secs            #      #   10^6bits/sec % SS
> us/KB
> > Before:
> > 212992   65507   60.00     1100662      0     9613.4     10.89
> 0.557
> > 212992           60.00      473474            4135.4     11.27
> 0.576
> >
> > After:
> > 212992   65507   60.00     1100413      0     9611.2     10.73
> 0.549
> > 212992           60.00      974132            8508.3     11.69
> 0.598
> >
> > Using bare metal the data is similar but not as dramatic as the
> throughput
> > increases from about 8.5Gb/s to 9.5Gb/s.
> >
> > Signed-off-by: Alexander Duyck <alexander.h.duyck@redhat.com>
>=20
> Has there been any update on this patch?  I submitted it just over a=20
> month ago now and it hasn't received any feedback.  I was hoping this=20
> could be submitted before the merge window closes for net-next.

It will be in the next series I push later today.

--=-/XbFWbB5648Sx9Fe4HLT
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAABCgAGBQJV5spEAAoJEOVv75VaS+3OIQgP/1sIoUHLI0O3Vp1kkazatzOM
ZQ6Tnep+V9B7mkEfqM6XdebG17pT74yew4+8l2I3qS8IVc5h1qTt/hElzjpcK+16
UfnU3KkHD287WfizWr95UKeUVOifcrLQGnRbXJ/r9VcHzSoj9mzv4alsHlL/xgBl
2Px8zuWd087UFXEt0KXSGiLHd5mhFMe9CztZlZzpRgoUcT/6IbsjNYIV+a+jWwAy
Os2vVUaYDhkVIWSyPuNdV8x+Tb80wYArgvEH8mhICu2FvR0sbi/gHu/nLkXiuNbo
p1J5HDQ+n5JB51JAO8q9f54AeorARm/unebRG14lEsL09+8/Xt7ofm0VP+YS5326
WPynjnY1zQvfaBVSEUTshc78oLwPhKEed0l3JhO0setKXHBHoYHtLeja1JcYdtoy
J5lXrlPhjvrM3yzeMIAWOhYin0v/IuSty8y+ZRLXG0+mC8CeZh8rH3HlCG2mJvZG
jiJgnolWVf5mECCBsGjSL280t4aqjeMiWMEr0g9T5Q8hO7kJ9UKTShmXKhvEG3qr
zhPjgBrjTGNna2s+CBvxZAnF4QvzuBNXUXVxArcvdkfleTNAJ8IXgwOY/ebnXL2s
jJTpSi1Hq9bHF7WfM4+7Dj0bkM9mCFvjnftQY5iKKTQnQaE/XA1L39hd427GBsBe
5wej5slW2z+dJ0bQ5q03
=GGP7
-----END PGP SIGNATURE-----

--=-/XbFWbB5648Sx9Fe4HLT--
