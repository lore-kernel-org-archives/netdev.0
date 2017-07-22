From: Salil Mehta <salil.mehta@huawei.com>
Subject: RE: [PATCH V3 net-next 1/8] net: hns3: Add support of HNS3 Ethernet
 Driver for hip08 SoC
Date: Sat, 22 Jul 2017 23:17:13 +0000
Message-ID: <F4CC6FACFEB3C54C9141D49AD221F7F93B81CBD6@FRAEML521-MBX.china.huawei.com>
References: <20170617172431.177044-1-salil.mehta@huawei.com>
 <20170617172431.177044-2-salil.mehta@huawei.com>
 <20170617175418.GB1974@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "davem@davemloft.net" <davem@davemloft.net>,
        "Zhuangyuzeng (Yisen)" <yisen.zhuang@huawei.com>,
        huangdaode <huangdaode@hisilicon.com>,
        "lipeng (Y)" <lipeng321@huawei.com>,
        "mehta.salil.lnk@gmail.com" <mehta.salil.lnk@gmail.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        Linuxarm <linuxarm@huawei.com>
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from lhrrgout.huawei.com ([194.213.3.17]:32162 "EHLO
        lhrrgout.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751614AbdGVXRv (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 22 Jul 2017 19:17:51 -0400
In-Reply-To: <20170617175418.GB1974@lunn.ch>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Andrew

> -----Original Message-----
> From: Andrew Lunn [mailto:andrew@lunn.ch]
> Sent: Saturday, June 17, 2017 6:54 PM
> To: Salil Mehta
> Cc: davem@davemloft.net; Zhuangyuzeng (Yisen); huangdaode; lipeng (Y);
> mehta.salil.lnk@gmail.com; netdev@vger.kernel.org; linux-
> kernel@vger.kernel.org; Linuxarm
> Subject: Re: [PATCH V3 net-next 1/8] net: hns3: Add support of HNS3
> Ethernet Driver for hip08 SoC
> 
> > +static int hns3_nic_net_up(struct net_device *ndev)
> > +{
> > +	struct hns3_nic_priv *priv = netdev_priv(ndev);
> > +	struct hnae3_handle *h = priv->ae_handle;
> > +	int i, j;
> > +	int ret;
> > +
> > +	ret = hns3_nic_init_irq(priv);
> > +	if (ret != 0) {
> 
>   	if (ret)
> 
> No need to compare with zero.
Sure, changed in V4 patch. 

Thanks
Salil
> 
> > +		netdev_err(ndev, "hns init irq failed! ret=%d\n", ret);
> > +		return ret;
> 
> > +static int hns3_nic_net_open(struct net_device *ndev)
> > +{
> > +	struct hns3_nic_priv *priv = netdev_priv(ndev);
> > +	struct hnae3_handle *h = priv->ae_handle;
> > +	int ret;
> > +
> > +	netif_carrier_off(ndev);
> > +
> > +	ret = netif_set_real_num_tx_queues(ndev, h->kinfo.num_tqps);
> > +	if (ret < 0) {
> > +		netdev_err(ndev, "netif_set_real_num_tx_queues fail,
> ret=%d!\n",
> > +			   ret);
> > +		return ret;
> > +	}
> 
> In general, functions return 0 for success, and something else for an
> error. So there is no need to do a comparison. Please remove all
> comparisons, unless it is really needed. It also makes the code look
> consistent. At the moment you sometime have < 0, sometime !=0, and
> sometimes no comparison at all.
Acknowledged, scanned and have changed in V4 patch. Please have a look.

Thanks
Salil
> 
> 	  Andrew
