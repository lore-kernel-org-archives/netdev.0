From: Salil Mehta <salil.mehta@huawei.com>
Subject: RE: [PATCH net] net: hns: Fix the device being used for dma mapping
 during TX
Date: Thu, 9 Feb 2017 10:20:35 +0000
Message-ID: <F4CC6FACFEB3C54C9141D49AD221F7F91A860CFF@lhreml503-mbx>
References: <20170209092409.202832-1-salil.mehta@huawei.com>
 <8729016553E3654398EA69218DA29EEF15A6FB63@cnshjmbx02>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "Zhuangyuzeng (Yisen)" <yisen.zhuang@huawei.com>,
        "mehta.salil.lnk@gmail.com" <mehta.salil.lnk@gmail.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        Linuxarm <linuxarm@huawei.com>,
        "Yankejian (Hackim Yim)" <yankejian@huawei.com>
To: YUAN Linyu <Linyu.Yuan@alcatel-sbell.com.cn>,
        "davem@davemloft.net" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> -----Original Message-----
> From: Salil Mehta
> Sent: Thursday, February 09, 2017 9:48 AM
> To: 'YUAN Linyu'; davem@davemloft.net
> Cc: Zhuangyuzeng (Yisen); mehta.salil.lnk@gmail.com;
> netdev@vger.kernel.org; linux-kernel@vger.kernel.org; Linuxarm;
> Yankejian (Hackim Yim)
> Subject: RE: [PATCH net] net: hns: Fix the device being used for dma
> mapping during TX
> 
> > -----Original Message-----
> > From: YUAN Linyu [mailto:Linyu.Yuan@alcatel-sbell.com.cn]
> > Sent: Thursday, February 09, 2017 9:36 AM
> > To: Salil Mehta; davem@davemloft.net
> > Cc: Zhuangyuzeng (Yisen); mehta.salil.lnk@gmail.com;
> > netdev@vger.kernel.org; linux-kernel@vger.kernel.org; Linuxarm;
> > Yankejian (Hackim Yim)
> > Subject: RE: [PATCH net] net: hns: Fix the device being used for dma
> > mapping during TX
> >
> >
> >
> > > -----Original Message-----
> > > From: netdev-owner@vger.kernel.org [mailto:netdev-
> > owner@vger.kernel.org]
> > > On Behalf Of Salil Mehta
> > > Sent: Thursday, February 09, 2017 5:24 PM
> > > To: davem@davemloft.net
> > > Cc: salil.mehta@huawei.com; yisen.zhuang@huawei.com;
> > > mehta.salil.lnk@gmail.com; netdev@vger.kernel.org;
> > > linux-kernel@vger.kernel.org; linuxarm@huawei.com; Kejian Yan
> > > Subject: [PATCH net] net: hns: Fix the device being used for dma
> > mapping during
> > > TX
> > >
> > > From: Kejian Yan <yankejian@huawei.com>
> > >
> > > This patch fixes the device being used to DMA map skb->data.
> > > Erroneous device assignment causes the crash when SMMU is enabled.
> > > This happens during TX since buffer gets DMA mapped with device
> > > correspondign to net_device and gets unmapped using the device
> > > related to DSAF.
> > >
> > > Signed-off-by: Kejian Yan <yankejian@huawei.com>
> > > Reviewed-by: Yisen Zhuang <yisen.zhuang@huawei.com>
> > > Signed-off-by: Salil Mehta <salil.mehta@huawei.com>
> > > ---
> > >  drivers/net/ethernet/hisilicon/hns/hns_enet.c |    2 +-
> > >  1 file changed, 1 insertion(+), 1 deletion(-)
> > >
> > > diff --git a/drivers/net/ethernet/hisilicon/hns/hns_enet.c
> > > b/drivers/net/ethernet/hisilicon/hns/hns_enet.c
> > > index 672b646..2b52a12 100644
> > > --- a/drivers/net/ethernet/hisilicon/hns/hns_enet.c
> > > +++ b/drivers/net/ethernet/hisilicon/hns/hns_enet.c
> > > @@ -305,7 +305,7 @@ int hns_nic_net_xmit_hw(struct net_device
> *ndev,
> > >  			struct hns_nic_ring_data *ring_data)
> > >  {
> > >  	struct hns_nic_priv *priv = netdev_priv(ndev);
> > > -	struct device *dev = priv->dev;
> > > +	struct device *dev = ring_to_dev(ring_data->ring);
> > >  	struct hnae_ring *ring = ring_data->ring;
> > struct device *dev = ring_to_dev(ring); ??????
> Yes, name of the macro is slight misnomer but this gets the dsaf
> device.
> Hope this answers your question?

I realized this lately, I think you meant below:
  	struct hnae_ring *ring = ring_data->ring;
	struct device *dev = ring_to_dev(ring);

I will correct this and float a patch. Thanks!

Best regards
Salil
> 
> Thanks
> Salil
> > >  	struct netdev_queue *dev_queue;
> > >  	struct skb_frag_struct *frag;
> > > --
> > > 1.7.9.5
> > >
