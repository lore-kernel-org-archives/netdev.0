From: Salil Mehta <salil.mehta@huawei.com>
Subject: RE: [PATCH net-next 1/9] net: hns3: Add support of HNS3 Ethernet
 Driver for hip08 SoC
Date: Sat, 17 Jun 2017 12:00:47 +0000
Message-ID: <F4CC6FACFEB3C54C9141D49AD221F7F93B7B2D1A@FRAEML521-MBS.china.huawei.com>
References: <20170610034630.493852-1-salil.mehta@huawei.com>
 <20170610034630.493852-2-salil.mehta@huawei.com>
 <BY2PR0701MB2005075560E4EA9F455049988DCF0@BY2PR0701MB2005.namprd07.prod.outlook.com>
 <F4CC6FACFEB3C54C9141D49AD221F7F93B7A1B62@FRAEML521-MBX.china.huawei.com>
 <BLUPR0701MB2004897373CA744917699BCA8DC30@BLUPR0701MB2004.namprd07.prod.outlook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "Zhuangyuzeng (Yisen)" <yisen.zhuang@huawei.com>,
        huangdaode <huangdaode@hisilicon.com>,
        "lipeng (Y)" <lipeng321@huawei.com>,
        "mehta.salil.lnk@gmail.com" <mehta.salil.lnk@gmail.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        Linuxarm <linuxarm@huawei.com>
To: "Mintz, Yuval" <Yuval.Mintz@cavium.com>,
        "davem@davemloft.net" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <BLUPR0701MB2004897373CA744917699BCA8DC30@BLUPR0701MB2004.namprd07.prod.outlook.com>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Yuval,

> -----Original Message-----
> From: Mintz, Yuval [mailto:Yuval.Mintz@cavium.com]
> Sent: Wednesday, June 14, 2017 9:04 AM
> To: Salil Mehta; davem@davemloft.net
> Cc: Zhuangyuzeng (Yisen); huangdaode; lipeng (Y);
> mehta.salil.lnk@gmail.com; netdev@vger.kernel.org; linux-
> kernel@vger.kernel.org; Linuxarm
> Subject: RE: [PATCH net-next 1/9] net: hns3: Add support of HNS3
> Ethernet Driver for hip08 SoC
> 
> > > > +static void hns3_nic_net_down(struct net_device *ndev) {
> > > > +	struct hns3_nic_priv *priv = netdev_priv(ndev);
> > > > +	struct hnae3_ae_ops *ops;
> > > > +	int i;
> > > > +
> > > > +	netif_tx_stop_all_queues(ndev);
> > > > +	netif_carrier_off(ndev);
> > > > +	netif_tx_disable(ndev);
> > > > +
> > > > +	ops = priv->ae_handle->ae_algo->ops;
> > > > +
> > > > +	if (ops->stop)
> > > > +		ops->stop(priv->ae_handle);
> > > > +
> > > > +	netif_tx_stop_all_queues(ndev);
> > >
> > > Looks a bit excessive. Why do you need all these
> > > netif_tx_stop_all_queues()?
> > If we are disabling the netdev. We need to stop scheduling the queues
> > associated with that netdev for TX, so we need this code. Why do you
> think
> > it is excessive?
> 
> Why do you need both netif_tx_disable() and netif_tx_stop_all_queues()?
> And why would you need to re-do netif_tx_stop_all_queues() after
> calling ops->stop()?
Oh yes! I missed this totally, In fact, netif_tx_diable is doing almost
the similar job what netif_tx_stop_all_queues() is doing with some
lock protection.

Thanks for identifying this. I will fix this in V3 patch. 

Thanks
Salil
> 
> > > Isn't mqprio going to override your priority2tc mapping with the
> one
> > > provided by user?
> > I guess you are referring to below code in the mqprio_init() - right?
> >
> > static int mqprio_init(struct Qdisc *sch, struct nlattr *opt)
> > {
> >   [...]
> > 	/* Always use supplied priority mappings */
> > 	for (i = 0; i < TC_BITMASK + 1; i++)
> > 		netdev_set_prio_tc_map(dev, i, qopt->prio_tc_map[i]);
> >   [...]
> > }
> >
> > In this case yes, you are right below code seems to be redundant:
> >
> >  +	/* Assign UP2TC map for the VSI */
> >  +	for (i = 0; i < HNAE3_MAX_TC; i++) {
> >  +		netdev_set_prio_tc_map(ndev,
> >  +				       kinfo->tc_info[i].up,
> >  +				       kinfo->tc_info[i].tc);
> >
> > Hope I am not missing anything here?
> You're not; That's what I meant.
Will remove this code in V3 patch.

Thanks
Salil
