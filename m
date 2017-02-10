From: "Lino Sanfilippo" <LinoSanfilippo@gmx.de>
Subject: Aw: RE: [PATCH net] net: hns: Fix the device being used for dma
 mapping during TX
Date: Fri, 10 Feb 2017 14:01:43 +0100
Message-ID: <trinity-0f73c31c-c719-4bc7-83f8-f5d01426e42b-1486731703602@3capp-gmx-bs14>
References: <20170209092409.202832-1-salil.mehta@huawei.com>
 <trinity-6f3e49ac-6fc0-4d36-a77a-44018a1b2e77-1486635890380@3capp-gmx-bs03>,
 <F4CC6FACFEB3C54C9141D49AD221F7F91A860E3E@lhreml503-mbx>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "davem@davemloft.net" <davem@davemloft.net>,
        "Zhuangyuzeng (Yisen)" <yisen.zhuang@huawei.com>,
        "mehta.salil.lnk@gmail.com" <mehta.salil.lnk@gmail.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        Linuxarm <linuxarm@huawei.com>,
        "Yankejian (Hackim Yim)" <yankejian@huawei.com>
To: "Salil Mehta" <salil.mehta@huawei.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <F4CC6FACFEB3C54C9141D49AD221F7F91A860E3E@lhreml503-mbx>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



> Gesendet: Donnerstag, 09. Februar 2017 um 12:30 Uhr
> Von: "Salil Mehta" <salil.mehta@huawei.com>
> An: "Lino Sanfilippo" <LinoSanfilippo@gmx.de>
> Cc: "davem@davemloft.net" <davem@davemloft.net>, "Zhuangyuzeng (Yisen)" <yisen.zhuang@huawei.com>, "mehta.salil.lnk@gmail.com" <mehta.salil.lnk@gmail.com>, "netdev@vger.kernel.org" <netdev@vger.kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Linuxarm <linuxarm@huawei.com>, "Yankejian (Hackim Yim)" <yankejian@huawei.com>
> Betreff: RE: [PATCH net] net: hns: Fix the device being used for dma mapping during TX
>
> > -----Original Message-----
> > From: Lino Sanfilippo [mailto:LinoSanfilippo@gmx.de]
> > Sent: Thursday, February 09, 2017 10:25 AM
> > To: Salil Mehta
> > Cc: davem@davemloft.net; Salil Mehta; Zhuangyuzeng (Yisen);
> > mehta.salil.lnk@gmail.com; netdev@vger.kernel.org; linux-
> > kernel@vger.kernel.org; Linuxarm; Yankejian (Hackim Yim)
> > Subject: Re: [PATCH net] net: hns: Fix the device being used for dma
> > mapping during TX
> > 
> > Hi,
> > 
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
> > b/drivers/net/ethernet/hisilicon/hns/hns_enet.c
> > > index 672b646..2b52a12 100644
> > > --- a/drivers/net/ethernet/hisilicon/hns/hns_enet.c
> > > +++ b/drivers/net/ethernet/hisilicon/hns/hns_enet.c
> > > @@ -305,7 +305,7 @@ int hns_nic_net_xmit_hw(struct net_device *ndev,
> > >  			struct hns_nic_ring_data *ring_data)
> > >  {
> > >  	struct hns_nic_priv *priv = netdev_priv(ndev);
> > > -	struct device *dev = priv->dev;
> > > +	struct device *dev = ring_to_dev(ring_data->ring);
> > >  	struct hnae_ring *ring = ring_data->ring;
> > >  	struct netdev_queue *dev_queue;
> > >  	struct skb_frag_struct *frag;
> > > --
> > 
> > I would say it should be the other way around: Use priv->dev for
> > mapping and
> > unmapping instead of ring_to_dev().
> Yes, you got it right. Ideally, it should be per-port and for
> legacy reasons we have it this way. In the current design, we have
> SMMU node per-dsaf and I guess we will not land in the right
> dma-ops if we use per-netdev platform-device/device right now.
> 

Ok, but how can it work if we set the DMA mask of the device object of 
the plaform_device (via dma_set_mask_and_coherent in the probe() function)
and do the actual mapping with a different device object? I dont know much about
 the low level dma handling but I can imagine that the mask is required to
do the mapping correctly. 

Regards,
Lino
