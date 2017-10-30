From: Madalin-cristian Bucur <madalin.bucur@nxp.com>
Subject: RE: [PATCH net-next] net: dpaa: remove init which already done in
 per-cpu allocation
Date: Mon, 30 Oct 2017 07:17:04 +0000
Message-ID: <DB3PR0402MB3849A9173292781582FDA910EC590@DB3PR0402MB3849.eurprd04.prod.outlook.com>
References: <1509241724-16997-1-git-send-email-cugyly@163.com>
 <DB3PR0402MB3849E758B1A2AD5FEF80DC27EC590@DB3PR0402MB3849.eurprd04.prod.outlook.com>
 <2673700892724b47842afbf3ab36c541@nokia-sbell.com>
 <DB3PR0402MB3849E5D5B33FD81575039E45EC590@DB3PR0402MB3849.eurprd04.prod.outlook.com>
 <87a1676ac7b74da3aa744c3f3cc6f0bf@nokia-sbell.com>
 <DB3PR0402MB384999DB4601EA7BE1E9159FEC590@DB3PR0402MB3849.eurprd04.prod.outlook.com>
 <3c448bbf3ebb4de0843b78af23435ba0@nokia-sbell.com>
 <DB3PR0402MB3849F054AF89B46D26E4DCB3EC590@DB3PR0402MB3849.eurprd04.prod.outlook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
Cc: "David S . Miller" <davem@davemloft.net>
To: Madalin-cristian Bucur <madalin.bucur@nxp.com>,
        "Yuan, Linyu (NSB - CN/Shanghai)" <linyu.yuan@nokia-sbell.com>,
        yuan linyu <cugyly@163.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "gregkh@linuxfoundation.org" <gregkh@linuxfoundation.org>,
        "edumazet@google.com" <edumazet@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-eopbgr10075.outbound.protection.outlook.com ([40.107.1.75]:45328
        "EHLO EUR02-HE1-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1751167AbdJ3HRH (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 30 Oct 2017 03:17:07 -0400
In-Reply-To: <DB3PR0402MB3849F054AF89B46D26E4DCB3EC590@DB3PR0402MB3849.eurprd04.prod.outlook.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> +Eric
>=20
> > -----Original Message-----
> > From: Yuan, Linyu (NSB - CN/Shanghai) [mailto:linyu.yuan@nokia-
> sbell.com]
> >
> > I just saw below accepted commit, it said "per cpu allocations are
> already
> > zeroed, no need to clear them again."
> >
> >
> https://emea01.safelinks.protection.outlook.com/?url=3Dhttps%3A%2F%2Fgit.=
ker
> nel.org%2Fpub%2Fscm%2Flinux%2Fkernel%2Fgit%2Fdavem%2Fnet-
> next.git%2Fcommit%2F%3Fid%3Dbfd8e5a407133e58a92a38ccf3d0ba6db81f22d8&data=
=3D
> 02%7C01%7Cmadalin.bucur%40nxp.com%7C4116c18371684740c41a08d51f65c6e9%7C68=
6
> ea1d3bc2b4c6fa92cd99c5c301635%7C0%7C0%7C636449444348895856&sdata=3DPBvP4J=
0ch
> 8o%2Bvif3C8D77dVxGW4vjUlCYwJzJcIzhFk%3D&reserved=3D0
> >
> > I will not touch memory sub-system, so I will not change this function
> > description.
> >
>=20
> Your particular change removes redundancy, it's fine. Having the memset
> documented
> somewhere would prevent similar redundancy from being added in the future=
.
>=20
> > > -----Original Message-----
> > > From: Madalin-cristian Bucur [mailto:madalin.bucur@nxp.com]
> > > Sent: Monday, October 30, 2017 1:56 PM
> > > To: Yuan, Linyu (NSB - CN/Shanghai); yuan linyu;
> netdev@vger.kernel.org;
> > > gregkh@linuxfoundation.org
> > > Cc: David S . Miller
> > > Subject: RE: [PATCH net-next] net: dpaa: remove init which already
> done
> > in
> > > per-cpu allocation
> > >
> > > Also here:
> > >
> > >
> > >
> https://emea01.safelinks.protection.outlook.com/?url=3Dhttp%3A%2F%2Felixi=
r.f
> ree-
> electrons.com%2Flinux%2Flatest%2Fsource%2Fmm%2Fpercpu.c%23L717&data=3D02%=
7C0
> 1%7Cmadalin.bucur%40nxp.com%7C4116c18371684740c41a08d51f65c6e9%7C686ea1d3=
b
> c2b4c6fa92cd99c5c301635%7C0%7C0%7C636449444348895856&sdata=3DG9AEcoAPE7yW=
H%2
> FHi56DP3zns8LaIixJ4xkuQCTJDI5E%3D&reserved=3D0
> > >
> > > Should the fact that the memory is zeroed be included in the function
> > > description?
> > >
> > > /**
> > >  * pcpu_alloc - the percpu allocator
> > >  * @size: size of area to allocate in bytes
> > >  * @align: alignment of area (max PAGE_SIZE)
> > >  * @reserved: allocate from the reserved chunk if available
> > >  * @gfp: allocation flags
> > >  *
> > >  * Allocate percpu area of @size bytes aligned at @align.  If @gfp
> > doesn't
> > >  * contain %GFP_KERNEL, the allocation is atomic.
> > >  *
> > >  * RETURNS:
> > >  * Percpu pointer to the allocated area on success, NULL on failure.
> > >  */
> > >
> > > Now it seems to be an implementation detail rather than a guarantee.
> > >
> > > Looking at Documentation/driver-model/devres.txt, the memset is not
> > > mentioned there either.
> > >
> > > > -----Original Message-----
> > > > From: Yuan, Linyu (NSB - CN/Shanghai) [mailto:linyu.yuan@nokia-
> > sbell.com]
> > > > Sent: Monday, October 30, 2017 7:21 AM
> > > > To: Madalin-cristian Bucur <madalin.bucur@nxp.com>; yuan linyu
> > > > <cugyly@163.com>; netdev@vger.kernel.org
> > > > Cc: David S . Miller <davem@davemloft.net>
> > > > Subject: RE: [PATCH net-next] net: dpaa: remove init which already
> > > > done in per-cpu allocation
> > > >
> > > >
> https://emea01.safelinks.protection.outlook.com/?url=3Dhttp%3A%2F%2Felixi=
r.f
> ree-
> electrons.com%2Flinux%2Flatest%2Fsource%2Fmm%2Fpercpu.c%23L1018&data=3D02=
%7C
> 01%7Cmadalin.bucur%40nxp.com%7C4116c18371684740c41a08d51f65c6e9%7C686ea1d=
3
> bc2b4c6fa92cd99c5c301635%7C0%7C0%7C636449444348895856&sdata=3D%2FOCOMao4j=
Jti
> ptOqUUXBbZMt5TNRXdFfyrqa1zIekAI%3D&reserved=3D0
> > > >
> > > > > -----Original Message-----
> > > > > From: Madalin-cristian Bucur [mailto:madalin.bucur@nxp.com]
> > > > > Sent: Monday, October 30, 2017 1:15 PM
> > > > > To: Yuan, Linyu (NSB - CN/Shanghai); yuan linyu;
> > netdev@vger.kernel.org
> > > > > Cc: David S . Miller
> > > > > Subject: RE: [PATCH net-next] net: dpaa: remove init which alread=
y
> > > > > done in per-cpu allocation
> > > > >
> > > > > Is the memset part documented?
> > > > > Can you point to the specific comment & code that does it?
> > > > >
> > > > > Thanks
> > > > >
> > > > > > -----Original Message-----
> > > > > > From: Yuan, Linyu (NSB - CN/Shanghai) [mailto:linyu.yuan@nokia-
> > > > sbell.com]
> > > > > > Sent: Monday, October 30, 2017 7:12 AM
> > > > > > To: Madalin-cristian Bucur <madalin.bucur@nxp.com>; yuan linyu
> > > > > > <cugyly@163.com>; netdev@vger.kernel.org
> > > > > > Cc: David S . Miller <davem@davemloft.net>
> > > > > > Subject: RE: [PATCH net-next] net: dpaa: remove init which
> already
> > > > done in
> > > > > > per-cpu allocation
> > > > > >
> > > > > > Hi,
> > > > > >
> > > > > > devm_alloc_percpu() will allocate per-cpu memory and memset
> > allocated
> > > > > > block content to 0.
> > > > > >
> > > > > > > -----Original Message-----
> > > > > > > From: Madalin-cristian Bucur [mailto:madalin.bucur@nxp.com]
> > > > > > > Sent: Monday, October 30, 2017 1:08 PM
> > > > > > > To: yuan linyu; netdev@vger.kernel.org
> > > > > > > Cc: David S . Miller; Yuan, Linyu (NSB - CN/Shanghai)
> > > > > > > Subject: RE: [PATCH net-next] net: dpaa: remove init which
> > > > > > > already done in per-cpu allocation
> > > > > > >
> > > > > > > Hi Yuan,
> > > > > > >
> > > > > > > Can you please give more details about this change you are
> > > > proposing?
> > > > > > >
> > > > > > > Regards,
> > > > > > > Madalin
> > > > > > >
> > > > > > > > -----Original Message-----
> > > > > > > > From: netdev-owner@vger.kernel.org
> > > > > > > [mailto:netdev-owner@vger.kernel.org]
> > > > > > > > On Behalf Of yuan linyu
> > > > > > > > Sent: Sunday, October 29, 2017 3:49 AM
> > > > > > > > To: netdev@vger.kernel.org
> > > > > > > > Cc: David S . Miller <davem@davemloft.net>; yuan linyu
> > > > > > > > <Linyu.Yuan@alcatel-sbell.com.cn>
> > > > > > > > Subject: [PATCH net-next] net: dpaa: remove init which
> already
> > > > done in
> > > > > > > > per-cpu allocation
> > > > > > > >
> > > > > > > > From: yuan linyu <Linyu.Yuan@alcatel-sbell.com.cn>
> > > > > > > >
> > > > > > > > Signed-off-by: yuan linyu <Linyu.Yuan@alcatel-sbell.com.cn>
> > > > > > > > ---
> > > > > > > >  drivers/net/ethernet/freescale/dpaa/dpaa_eth.c | 4 ----
> > > > > > > >  1 file changed, 4 deletions(-)
> > > > > > > >
> > > > > > > > diff --git a/drivers/net/ethernet/freescale/dpaa/dpaa_eth.c
> > > > > > > > b/drivers/net/ethernet/freescale/dpaa/dpaa_eth.c
> > > > > > > > index a8d0be8..1ccc316 100644
> > > > > > > > --- a/drivers/net/ethernet/freescale/dpaa/dpaa_eth.c
> > > > > > > > +++ b/drivers/net/ethernet/freescale/dpaa/dpaa_eth.c
> > > > > > > > @@ -2814,10 +2814,6 @@ static int dpaa_eth_probe(struct
> > > > > > > platform_device
> > > > > > > > *pdev)
> > > > > > > >  		err =3D -ENOMEM;
> > > > > > > >  		goto free_dpaa_fqs;
> > > > > > > >  	}
> > > > > > > > -	for_each_possible_cpu(i) {
> > > > > > > > -		percpu_priv =3D per_cpu_ptr(priv->percpu_priv, i);
> > > > > > > > -		memset(percpu_priv, 0, sizeof(*percpu_priv));
> > > > > > > > -	}
> > > > > > > >
> > > > > > > >  	priv->num_tc =3D 1;
> > > > > > > >  	netif_set_real_num_tx_queues(net_dev, priv->num_tc *
> > > > > > > > DPAA_TC_TXQ_NUM);
> > > > > > > > --
> > > > > > > > 2.7.4
> > > > > > > >
