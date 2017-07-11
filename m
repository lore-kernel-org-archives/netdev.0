From: Leon Romanovsky <leon@kernel.org>
Subject: Re: [PATCH iproute2 V3 3/4] rdma: Add link object
Date: Tue, 11 Jul 2017 09:33:26 +0300
Message-ID: <20170711063326.GR1528@mtr-leonro.local>
References: <20170704075541.12544-1-leon@kernel.org>
 <20170704075541.12544-4-leon@kernel.org>
 <20170710081307.GE1853@nanopsycho>
 <20170710162223.GO1528@mtr-leonro.local>
 <20170710182828.GF1853@nanopsycho>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
        protocol="application/pgp-signature"; boundary="6ys2uLYBf50XP5fk"
Cc: Stephen Hemminger <stephen@networkplumber.org>,
        Doug Ledford <dledford@redhat.com>,
        Ariel Almog <ariela@mellanox.com>,
        Linux RDMA <linux-rdma@vger.kernel.org>,
        Linux Netdev <netdev@vger.kernel.org>
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.kernel.org ([198.145.29.99]:57842 "EHLO mail.kernel.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1755296AbdGKGdm (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 11 Jul 2017 02:33:42 -0400
Content-Disposition: inline
In-Reply-To: <20170710182828.GF1853@nanopsycho>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--6ys2uLYBf50XP5fk
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Mon, Jul 10, 2017 at 08:28:28PM +0200, Jiri Pirko wrote:
> Mon, Jul 10, 2017 at 06:22:23PM CEST, leon@kernel.org wrote:
> >On Mon, Jul 10, 2017 at 10:13:07AM +0200, Jiri Pirko wrote:
> >> Tue, Jul 04, 2017 at 09:55:40AM CEST, leon@kernel.org wrote:
> >> >From: Leon Romanovsky <leonro@mellanox.com>
> >> >
> >> >Link (port) object represent struct ib_port to the user space.
> >> >
> >> >Link properties:
> >> > * Port capabilities
> >> > * IB subnet prefix
> >> > * LID, SM_LID and LMC
> >> > * Port state
> >> > * Physical state
> >> >
> >> >Signed-off-by: Leon Romanovsky <leonro@mellanox.com>
> >> >---
> >> > rdma/Makefile |   2 +-
> >> > rdma/link.c   | 280 ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
> >> > rdma/rdma.c   |   3 +-
> >> > rdma/utils.c  |   5 ++
> >> > 4 files changed, 288 insertions(+), 2 deletions(-)
> >> > create mode 100644 rdma/link.c
> >> >
> >> >diff --git a/rdma/Makefile b/rdma/Makefile
> >> >index 123d7ac5..1a9e4b1a 100644
> >> >--- a/rdma/Makefile
> >> >+++ b/rdma/Makefile
> >> >@@ -2,7 +2,7 @@ include ../Config
> >> >
> >> > ifeq ($(HAVE_MNL),y)
> >> >
> >> >-RDMA_OBJ = rdma.o utils.o dev.o
> >> >+RDMA_OBJ = rdma.o utils.o dev.o link.o
> >> >
> >> > TARGETS=rdma
> >> > CFLAGS += $(shell $(PKG_CONFIG) libmnl --cflags)
> >> >diff --git a/rdma/link.c b/rdma/link.c
> >> >new file mode 100644
> >> >index 00000000..f92b4cef
> >> >--- /dev/null
> >> >+++ b/rdma/link.c
> >> >@@ -0,0 +1,280 @@
> >> >+/*
> >> >+ * link.c	RDMA tool
> >> >+ *
> >> >+ *              This program is free software; you can redistribute it and/or
> >> >+ *              modify it under the terms of the GNU General Public License
> >> >+ *              as published by the Free Software Foundation; either version
> >> >+ *              2 of the License, or (at your option) any later version.
> >> >+ *
> >> >+ * Authors:     Leon Romanovsky <leonro@mellanox.com>
> >> >+ */
> >> >+
> >> >+#include "rdma.h"
> >> >+
> >> >+static int link_help(struct rdma *rd)
> >> >+{
> >> >+	pr_out("Usage: %s link show [DEV/PORT_INDEX]\n", rd->filename);
> >> >+	return 0;
> >> >+}
> >> >+
> >> >+static void link_print_caps(struct nlattr **tb)
> >> >+{
> >> >+	uint64_t caps;
> >> >+	uint32_t idx;
> >> >+
> >> >+	/*
> >> >+	 * FIXME: move to indexes when kernel will start exporting them.
> >>
> >> Not exported yet?
> >
> >Not yet, I want to minimize the UAPI export from kernel before user-space
> >part is accepted.
>
> I don't get it. If you need it in userspace, you should expose it. Why
> to wait? What am I missing?

Mainly my attempt to avoid constant rebasing for four series at the
same time. One for rdmatool, one for RDMA netlink, one for RDMA UAPI changes
and one for rdma-core [1] which should reuse those exported structures too.

[1] http://github.com/linux-rdma/rdma-core

Thanks

--6ys2uLYBf50XP5fk
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAEBCAAdFiEEkhr/r4Op1/04yqaB5GN7iDZyWKcFAllkcTYACgkQ5GN7iDZy
WKffmA/9GdK6DKj75mAZL8vqsCPOhI04MelF3bCeW09mz9hewsS5xlokg/YIN4K/
gx84on9S72mSlxYDHRvAIGZBSH1ALQQdj0e1/YX5LY7sveyNvkUWRujMW3AHI/y2
SFTJLfEQJT4w0DvFoNh/F/SuhqZMn/LsQDz4IBb5VbadecwwOxK8YTO7ATyRcFK+
eFzalwxmds9rPfAMKEuRgETXjfzbMx2iZrjZBsWJ1f3pEeRu9Vleih9FCviTAGOZ
s2n0haS7VOYSQqBtHoGDLhuC4DaX+aMTn3RxXWoJqZKQeLX/fTqrjUo5M7dbLPo5
aWgs64KRv+de6m83QiryVRqrn8ZjyRqJXiEjisOuBj4fmNs1D/7MJNzZSLW/56Ne
V6n+QxQtwpb+lkZ+g4AGLsUrNQa2f8h2ZRl6MRsTMwZ6+QSRpmgcRlIbHdaL33St
nIpdTN/ERgbVfhqKYFOeiJMGy4uZ7VRrLZact2gs029QQ7s+kuHCSDvr1p1w0dFb
o+Ua2Zh9ceCKS3dbHpjKB0XtNoJ+NEPJRRsqwNZlWnsBJO1Ic6XQ3qjuIF7KyYr2
5csshfquaoCzkoLga/InOHqCwO+3NeXMQFJ+OfLuryncg4f3xzWw8DZIX3UoRt7c
h73Ati1ed4CSmCSF4tebjGUUyI9BrvURnYWnZEuE6U0HHFUPLcw=
=mbYd
-----END PGP SIGNATURE-----

--6ys2uLYBf50XP5fk--
