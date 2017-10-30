From: "Yuan, Linyu (NSB - CN/Shanghai)" <linyu.yuan@nokia-sbell.com>
Subject: RE: [PATCH net-next] net: dpaa: remove init which already done in
 per-cpu allocation
Date: Mon, 30 Oct 2017 05:12:29 +0000
Message-ID: <2673700892724b47842afbf3ab36c541@nokia-sbell.com>
References: <1509241724-16997-1-git-send-email-cugyly@163.com>
 <DB3PR0402MB3849E758B1A2AD5FEF80DC27EC590@DB3PR0402MB3849.eurprd04.prod.outlook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "David S . Miller" <davem@davemloft.net>
To: Madalin-cristian Bucur <madalin.bucur@nxp.com>,
        yuan linyu <cugyly@163.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cnshjsmin05.nokia-sbell.com ([116.246.26.45]:62424 "EHLO
        cnshjsmin05.nokia-sbell.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1752150AbdJ3F1c (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 30 Oct 2017 01:27:32 -0400
In-Reply-To: <DB3PR0402MB3849E758B1A2AD5FEF80DC27EC590@DB3PR0402MB3849.eurprd04.prod.outlook.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

devm_alloc_percpu() will allocate per-cpu memory and memset allocated block content to 0.

> -----Original Message-----
> From: Madalin-cristian Bucur [mailto:madalin.bucur@nxp.com]
> Sent: Monday, October 30, 2017 1:08 PM
> To: yuan linyu; netdev@vger.kernel.org
> Cc: David S . Miller; Yuan, Linyu (NSB - CN/Shanghai)
> Subject: RE: [PATCH net-next] net: dpaa: remove init which already done in
> per-cpu allocation
> 
> Hi Yuan,
> 
> Can you please give more details about this change you are proposing?
> 
> Regards,
> Madalin
> 
> > -----Original Message-----
> > From: netdev-owner@vger.kernel.org
> [mailto:netdev-owner@vger.kernel.org]
> > On Behalf Of yuan linyu
> > Sent: Sunday, October 29, 2017 3:49 AM
> > To: netdev@vger.kernel.org
> > Cc: David S . Miller <davem@davemloft.net>; yuan linyu
> > <Linyu.Yuan@alcatel-sbell.com.cn>
> > Subject: [PATCH net-next] net: dpaa: remove init which already done in
> > per-cpu allocation
> >
> > From: yuan linyu <Linyu.Yuan@alcatel-sbell.com.cn>
> >
> > Signed-off-by: yuan linyu <Linyu.Yuan@alcatel-sbell.com.cn>
> > ---
> >  drivers/net/ethernet/freescale/dpaa/dpaa_eth.c | 4 ----
> >  1 file changed, 4 deletions(-)
> >
> > diff --git a/drivers/net/ethernet/freescale/dpaa/dpaa_eth.c
> > b/drivers/net/ethernet/freescale/dpaa/dpaa_eth.c
> > index a8d0be8..1ccc316 100644
> > --- a/drivers/net/ethernet/freescale/dpaa/dpaa_eth.c
> > +++ b/drivers/net/ethernet/freescale/dpaa/dpaa_eth.c
> > @@ -2814,10 +2814,6 @@ static int dpaa_eth_probe(struct
> platform_device
> > *pdev)
> >  		err = -ENOMEM;
> >  		goto free_dpaa_fqs;
> >  	}
> > -	for_each_possible_cpu(i) {
> > -		percpu_priv = per_cpu_ptr(priv->percpu_priv, i);
> > -		memset(percpu_priv, 0, sizeof(*percpu_priv));
> > -	}
> >
> >  	priv->num_tc = 1;
> >  	netif_set_real_num_tx_queues(net_dev, priv->num_tc *
> > DPAA_TC_TXQ_NUM);
> > --
> > 2.7.4
> >
