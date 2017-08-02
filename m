From: Salil Mehta <salil.mehta@huawei.com>
Subject: RE: [PATCH V4 net-next 1/8] net: hns3: Add support of HNS3 Ethernet
 Driver for hip08 SoC
Date: Wed, 2 Aug 2017 16:38:12 +0000
Message-ID: <F4CC6FACFEB3C54C9141D49AD221F7F93B83761C@FRAEML521-MBX.china.huawei.com>
References: <20170722220942.78852-1-salil.mehta@huawei.com>
 <20170722220942.78852-2-salil.mehta@huawei.com>
 <79a3a952-acae-2a51-0d49-46acaf92cf3b@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "Zhuangyuzeng (Yisen)" <yisen.zhuang@huawei.com>,
        huangdaode <huangdaode@hisilicon.com>,
        "lipeng (Y)" <lipeng321@huawei.com>,
        "mehta.salil.lnk@gmail.com" <mehta.salil.lnk@gmail.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        "linux-rdma@vger.kernel.org" <linux-rdma@vger.kernel.org>,
        Linuxarm <linuxarm@huawei.com>
To: Florian Fainelli <f.fainelli@gmail.com>,
        "davem@davemloft.net" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Florian,

> -----Original Message-----
> From: Salil Mehta
> Sent: Thursday, July 27, 2017 9:45 PM
> To: 'Florian Fainelli'; davem@davemloft.net
> Cc: Zhuangyuzeng (Yisen); huangdaode; lipeng (Y);
> mehta.salil.lnk@gmail.com; netdev@vger.kernel.org; linux-
> kernel@vger.kernel.org; linux-rdma@vger.kernel.org; Linuxarm
> Subject: RE: [PATCH V4 net-next 1/8] net: hns3: Add support of HNS3
> Ethernet Driver for hip08 SoC
> 
> Hi Florian,
> 
> > -----Original Message-----
> > From: Florian Fainelli [mailto:f.fainelli@gmail.com]
> > Sent: Sunday, July 23, 2017 6:24 PM
> > To: Salil Mehta; davem@davemloft.net
> > Cc: Zhuangyuzeng (Yisen); huangdaode; lipeng (Y);
> > mehta.salil.lnk@gmail.com; netdev@vger.kernel.org; linux-
> > kernel@vger.kernel.org; linux-rdma@vger.kernel.org; Linuxarm
> > Subject: Re: [PATCH V4 net-next 1/8] net: hns3: Add support of HNS3
> > Ethernet Driver for hip08 SoC
> >
> >
> >
> > On 07/22/2017 03:09 PM, Salil Mehta wrote:
> > > This patch adds the support of Hisilicon Network Subsystem 3
> > > Ethernet driver to hip08 family of SoCs.
> > >
> > > This driver includes basic Rx/Tx functionality. It also includes
> > > the client registration code with the HNAE3(Hisilicon Network
> > > Acceleration Engine 3) framework.
> > >
> > > This work provides the initial support to the hip08 SoC and
> > > would incrementally add features or enhancements.
> > >
> > > Signed-off-by: Daode Huang <huangdaode@hisilicon.com>
> > > Signed-off-by: lipeng <lipeng321@huawei.com>
> > > Signed-off-by: Salil Mehta <salil.mehta@huawei.com>
> > > Signed-off-by: Yisen Zhuang <yisen.zhuang@huawei.com>

[...]

> 
> >
> > > +		hns3_nic_reclaim_one_desc(ring, &bytes, &pkts);
> > > +		/* Issue prefetch for next Tx descriptor */
> > > +		prefetch(&ring->desc_cb[ring->next_to_clean]);
> > > +		budget--;
> > > +	}
> > > +
> > > +	ring->tqp_vector->tx_group.total_bytes += bytes;
> > > +	ring->tqp_vector->tx_group.total_packets += pkts;
> > > +
> > > +	dev_queue = netdev_get_tx_queue(netdev, ring->tqp->tqp_index);
> > > +	netdev_tx_completed_queue(dev_queue, pkts, bytes);
> >
> > Where is flow control happening? Should not you wake the transmit
> queue
> > if you had to stop it somehow?
> Forgive me, I could not get this part. Flow control of what?
As discussed with you earlier, I have fixed the queue wakeup part
in Patch V6. Please have a look at it. Thanks!

Best regards 
Salil
> 
> 
> >
> > I kind of stopped reviewing here.
> > --
> > Florian
