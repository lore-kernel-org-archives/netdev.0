From: Eli Cohen <eli@dev.mellanox.co.il>
Subject: Re: FW: [PATCH 13/17] mlx4: Add blue flame support for kernel
 consumers
Date: Mon, 7 Mar 2011 23:36:48 +0200
Message-ID: <20110307213648.GA18682@mtldesk30>
References: <CFE9BFE80FFE4D4892AA5D31387E310F02F3ED@mtldag01.mtl.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: roland@purestorage.com, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:40541 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754055Ab1CGVeu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Mar 2011 16:34:50 -0500
Received: by wyg36 with SMTP id 36so4614156wyg.19
        for <netdev@vger.kernel.org>; Mon, 07 Mar 2011 13:34:46 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <CFE9BFE80FFE4D4892AA5D31387E310F02F3ED@mtldag01.mtl.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>=20
> On Mon, Mar 7, 2011 at 2:17 AM, Yevgeny Petrilin
> <yevgenyp@mellanox.co.il> wrote:
> > + =A0 =A0 =A0 if (map_bf_area(dev))
> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 mlx4_dbg(dev, "Kernel support for blu=
e flame is not available for kernels < 2.6.28\n");
>=20
> This seems like a really bad error message.  Can map_bf_area() actual=
ly fail?

I agree that this message is inappropriate here; it is originiated
from the OFED patches which support older kernels too.
As for the question if a message is justified here at all, I think the
answer is yes becuase of this:

+static int map_bf_area(struct mlx4_dev *dev)
+{
+       struct mlx4_priv *priv =3D mlx4_priv(dev);
+       resource_size_t bf_start;
+       resource_size_t bf_len;
+       int err =3D 0;
+
+       bf_start =3D pci_resource_start(dev->pdev, 2) +
(dev->caps.num_uars << PAGE_SHIFT);
+       bf_len =3D pci_resource_len(dev->pdev, 2) - (dev->caps.num_uars
<< PAGE_SHIFT);
+       priv->bf_mapping =3D io_mapping_create_wc(bf_start, bf_len);
+       if (!priv->bf_mapping)
+               err =3D -ENOMEM;

Specifically, some archs may not support write combining.
=20
