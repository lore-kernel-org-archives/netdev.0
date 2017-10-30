From: Madalin-cristian Bucur <madalin.bucur@nxp.com>
Subject: RE: [PATCH net-next] net: dpaa: remove init which already done in
 per-cpu allocation
Date: Mon, 30 Oct 2017 07:13:41 +0000
Message-ID: <DB3PR0402MB3849F054AF89B46D26E4DCB3EC590@DB3PR0402MB3849.eurprd04.prod.outlook.com>
References: <1509241724-16997-1-git-send-email-cugyly@163.com>
 <DB3PR0402MB3849E758B1A2AD5FEF80DC27EC590@DB3PR0402MB3849.eurprd04.prod.outlook.com>
 <2673700892724b47842afbf3ab36c541@nokia-sbell.com>
 <DB3PR0402MB3849E5D5B33FD81575039E45EC590@DB3PR0402MB3849.eurprd04.prod.outlook.com>
 <87a1676ac7b74da3aa744c3f3cc6f0bf@nokia-sbell.com>
 <DB3PR0402MB384999DB4601EA7BE1E9159FEC590@DB3PR0402MB3849.eurprd04.prod.outlook.com>
 <3c448bbf3ebb4de0843b78af23435ba0@nokia-sbell.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
Cc: "David S . Miller" <davem@davemloft.net>
To: "Yuan, Linyu (NSB - CN/Shanghai)" <linyu.yuan@nokia-sbell.com>,
        yuan linyu <cugyly@163.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "gregkh@linuxfoundation.org" <gregkh@linuxfoundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-eopbgr10059.outbound.protection.outlook.com ([40.107.1.59]:4896
        "EHLO EUR02-HE1-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1751365AbdJ3HNp (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 30 Oct 2017 03:13:45 -0400
In-Reply-To: <3c448bbf3ebb4de0843b78af23435ba0@nokia-sbell.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

+Eric

> -----Original Message-----
> From: Yuan, Linyu (NSB - CN/Shanghai) [mailto:linyu.yuan@nokia-sbell.com]
>=20
> I just saw below accepted commit, it said "per cpu allocations are alread=
y
> zeroed, no need to clear them again."
>=20
> https://git.kernel.org/pub/scm/linux/kernel/git/davem/net-next.git/commit=
/?id=3Dbfd8e5a407133e58a92a38ccf3d0ba6db81f22d8
>=20
> I will not touch memory sub-system, so I will not change this function
> description.
>=20

Your particular change removes redundancy, it's fine. Having the memset doc=
umented
somewhere would prevent similar redundancy from being added in the future.

> > -----Original Message-----
> > From: Madalin-cristian Bucur [mailto:madalin.bucur@nxp.com]
> > Sent: Monday, October 30, 2017 1:56 PM
> > To: Yuan, Linyu (NSB - CN/Shanghai); yuan linyu; netdev@vger.kernel.org=
;
> > gregkh@linuxfoundation.org
> > Cc: David S . Miller
> > Subject: RE: [PATCH net-next] net: dpaa: remove init which already done
> in
> > per-cpu allocation
> >
> > Also here:
> >
> >
> > http://elixir.free-electrons.com/linux/latest/source/mm/percpu.c#L717
> >
> > Should the fact that the memory is zeroed be included in the function
> > description?
> >
> > /**
> >  * pcpu_alloc - the percpu allocator
> >  * @size: size of area to allocate in bytes
> >  * @align: alignment of area (max PAGE_SIZE)
> >  * @reserved: allocate from the reserved chunk if available
> >  * @gfp: allocation flags
> >  *
> >  * Allocate percpu area of @size bytes aligned at @align.  If @gfp
> doesn't
> >  * contain %GFP_KERNEL, the allocation is atomic.
> >  *
> >  * RETURNS:
> >  * Percpu pointer to the allocated area on success, NULL on failure.
> >  */
> >
> > Now it seems to be an implementation detail rather than a guarantee.
> >
> > Looking at Documentation/driver-model/devres.txt, the memset is not
> > mentioned there either.
> >
> > > -----Original Message-----
> > > From: Yuan, Linyu (NSB - CN/Shanghai) [mailto:linyu.yuan@nokia-
> sbell.com]
> > > Sent: Monday, October 30, 2017 7:21 AM
> > > To: Madalin-cristian Bucur <madalin.bucur@nxp.com>; yuan linyu
> > > <cugyly@163.com>; netdev@vger.kernel.org
> > > Cc: David S . Miller <davem@davemloft.net>
> > > Subject: RE: [PATCH net-next] net: dpaa: remove init which already
> > > done in per-cpu allocation
> > >
> > > http://elixir.free-electrons.com/linux/latest/source/mm/percpu.c#L101=
8
> > >
> > > > -----Original Message-----
> > > > From: Madalin-cristian Bucur [mailto:madalin.bucur@nxp.com]
> > > > Sent: Monday, October 30, 2017 1:15 PM
> > > > To: Yuan, Linyu (NSB - CN/Shanghai); yuan linyu;
> netdev@vger.kernel.org
> > > > Cc: David S . Miller
> > > > Subject: RE: [PATCH net-next] net: dpaa: remove init which already
> > > > done in per-cpu allocation
> > > >
> > > > Is the memset part documented?
> > > > Can you point to the specific comment & code that does it?
> > > >
> > > > Thanks
> > > >
> > > > > -----Original Message-----
> > > > > From: Yuan, Linyu (NSB - CN/Shanghai) [mailto:linyu.yuan@nokia-
> > > sbell.com]
> > > > > Sent: Monday, October 30, 2017 7:12 AM
> > > > > To: Madalin-cristian Bucur <madalin.bucur@nxp.com>; yuan linyu
> > > > > <cugyly@163.com>; netdev@vger.kernel.org
> > > > > Cc: David S . Miller <davem@davemloft.net>
> > > > > Subject: RE: [PATCH net-next] net: dpaa: remove init which alread=
y
> > > done in
> > > > > per-cpu allocation
> > > > >
> > > > > Hi,
> > > > >
> > > > > devm_alloc_percpu() will allocate per-cpu memory and memset
> allocated
> > > > > block content to 0.
> > > > >
> > > > > > -----Original Message-----
> > > > > > From: Madalin-cristian Bucur [mailto:madalin.bucur@nxp.com]
> > > > > > Sent: Monday, October 30, 2017 1:08 PM
> > > > > > To: yuan linyu; netdev@vger.kernel.org
> > > > > > Cc: David S . Miller; Yuan, Linyu (NSB - CN/Shanghai)
> > > > > > Subject: RE: [PATCH net-next] net: dpaa: remove init which
> > > > > > already done in per-cpu allocation
> > > > > >
> > > > > > Hi Yuan,
> > > > > >
> > > > > > Can you please give more details about this change you are
> > > proposing?
> > > > > >
> > > > > > Regards,
> > > > > > Madalin
> > > > > >
> > > > > > > -----Original Message-----
> > > > > > > From: netdev-owner@vger.kernel.org
> > > > > > [mailto:netdev-owner@vger.kernel.org]
> > > > > > > On Behalf Of yuan linyu
> > > > > > > Sent: Sunday, October 29, 2017 3:49 AM
> > > > > > > To: netdev@vger.kernel.org
> > > > > > > Cc: David S . Miller <davem@davemloft.net>; yuan linyu
> > > > > > > <Linyu.Yuan@alcatel-sbell.com.cn>
> > > > > > > Subject: [PATCH net-next] net: dpaa: remove init which alread=
y
> > > done in
> > > > > > > per-cpu allocation
> > > > > > >
> > > > > > > From: yuan linyu <Linyu.Yuan@alcatel-sbell.com.cn>
> > > > > > >
> > > > > > > Signed-off-by: yuan linyu <Linyu.Yuan@alcatel-sbell.com.cn>
> > > > > > > ---
> > > > > > >  drivers/net/ethernet/freescale/dpaa/dpaa_eth.c | 4 ----
> > > > > > >  1 file changed, 4 deletions(-)
> > > > > > >
> > > > > > > diff --git a/drivers/net/ethernet/freescale/dpaa/dpaa_eth.c
> > > > > > > b/drivers/net/ethernet/freescale/dpaa/dpaa_eth.c
> > > > > > > index a8d0be8..1ccc316 100644
> > > > > > > --- a/drivers/net/ethernet/freescale/dpaa/dpaa_eth.c
> > > > > > > +++ b/drivers/net/ethernet/freescale/dpaa/dpaa_eth.c
> > > > > > > @@ -2814,10 +2814,6 @@ static int dpaa_eth_probe(struct
> > > > > > platform_device
> > > > > > > *pdev)
> > > > > > >  		err =3D -ENOMEM;
> > > > > > >  		goto free_dpaa_fqs;
> > > > > > >  	}
> > > > > > > -	for_each_possible_cpu(i) {
> > > > > > > -		percpu_priv =3D per_cpu_ptr(priv->percpu_priv, i);
> > > > > > > -		memset(percpu_priv, 0, sizeof(*percpu_priv));
> > > > > > > -	}
> > > > > > >
> > > > > > >  	priv->num_tc =3D 1;
> > > > > > >  	netif_set_real_num_tx_queues(net_dev, priv->num_tc *
> > > > > > > DPAA_TC_TXQ_NUM);
> > > > > > > --
> > > > > > > 2.7.4
> > > > > > >
