From: Jack Morgenstein <jackm@dev.mellanox.co.il>
Subject: Re: [ofa-general] InfiniBand/RDMA merge plans for 2.6.24
Date: Tue, 18 Sep 2007 09:09:49 +0200
Message-ID: <200709180909.50029.jackm@dev.mellanox.co.il>
References: <adahclymos8.fsf@cisco.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Roland Dreier <rdreier@cisco.com>, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, tziporet@mellanox.co.il
To: general@lists.openfabrics.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ug-out-1314.google.com ([66.249.92.169]:62692 "EHLO
	ug-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754189AbXIRHFW convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 Sep 2007 03:05:22 -0400
Received: by ug-out-1314.google.com with SMTP id z38so50372ugc
        for <netdev@vger.kernel.org>; Tue, 18 Sep 2007 00:05:20 -0700 (PDT)
In-Reply-To: <adahclymos8.fsf@cisco.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thursday 13 September 2007 20:57, Roland Dreier wrote:
> HW specific:
>=20
> =A0- I already merged patches to enable MSI-X by default for mthca an=
d
> =A0 =A0mlx4. =A0I hope there aren't too many systems that get hosed i=
f a
> =A0 =A0MSI-X interrupt is generated.
>=20
> =A0- Jack and Michael's mlx4 FMR support. =A0Will merge I guess, alth=
ough
> =A0 =A0I do hope to have time to address the DMA API abuse that is be=
ing
> =A0 =A0copied from mthca, so that mlx4 and mthca work in Xen domU.
>=20
> =A0- ehca patch queue. =A0Will merge, pending fixes for the few minor
> =A0 =A0issues I commented on.
>=20
> =A0- Steve's mthca router mode support. =A0Would be nice to see a rev=
iew
> =A0 =A0from someone at Mellanox.
>=20
> =A0- Arthur's mthca doorbell alignment fixes. =A0I will experiment wi=
th a
> =A0 =A0few different approaches and post what I like (and fix mlx4 as
> =A0 =A0well). =A0I hope Arthur can review.
>=20
> =A0- Michael's mlx4 WQE shrinking patch. =A0Not sure yet; I'll reply =
to
> =A0 =A0the latest patch directly.
>=20
Missing from this list (IMPORTANT patch!):
[ofa-general] [PATCH 2 of 2] IB/mlx4: Handle new FW requirement for sen=
d request prefetching, for WQE sg lists
(Posted by me to list on Sept 4)
{patch header:=20
This is an addendum to Roland's commit 0e6e74162164d908edf7889ac66dca09=
e7505745
(June 18). This addendum adds prefetch headroom marking processing for =
s/g segments.

We write s/g segments in reverse order into the WQE, in order to guaran=
tee
that the first dword of all cachelines containing s/g segments is writt=
en last
(overwriting the headroom invalidation pattern). The entire cacheline w=
ill thus
contain valid data when the invalidation pattern is overwritten.
}
This patch series (1 of 2 is for libmlx4, the same issue).
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D

Also, I'm now posting (in a separate post) the following patch to mlx4,=
 which is important:
  display the following device information via sysfs:
  board_id, fw_ver, hw_rev, hca_type.

  The info is displayed under directory /sys/class/infiniband/mlx4_x, w=
here x is
  the pci bus sequence number (starting from zero).

  This patch makes information available to ibstat and ibv_devinfo unde=
r the
  same directory as is used for tavor/arbel/sinai -- thus requiring no =
userspace
  modifications.

- Jack


