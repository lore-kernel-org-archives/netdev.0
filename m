From: Salil Mehta <salil.mehta@huawei.com>
Subject: RE: [PATCH V2 net-next 1/8] net: hns3: Add support of HNS3 Ethernet
 Driver for hip08 SoC
Date: Sat, 22 Jul 2017 23:57:46 +0000
Message-ID: <F4CC6FACFEB3C54C9141D49AD221F7F93B81CD1C@FRAEML521-MBX.china.huawei.com>
References: <20170613231035.494020-1-salil.mehta@huawei.com>
        <20170613231035.494020-2-salil.mehta@huawei.com>
 <20170619084801.7920e30d@xeon-e3>
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
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170619084801.7920e30d@xeon-e3>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Stephen,

> -----Original Message-----
> From: Stephen Hemminger [mailto:stephen@networkplumber.org]
> Sent: Monday, June 19, 2017 4:48 PM
> To: Salil Mehta
> Cc: davem@davemloft.net; Zhuangyuzeng (Yisen); huangdaode; lipeng (Y);
> mehta.salil.lnk@gmail.com; netdev@vger.kernel.org; linux-
> kernel@vger.kernel.org; Linuxarm
> Subject: Re: [PATCH V2 net-next 1/8] net: hns3: Add support of HNS3
> Ethernet Driver for hip08 SoC
> 
> On Wed, 14 Jun 2017 00:10:28 +0100
> Salil Mehta <salil.mehta@huawei.com> wrote:
> 
> > +hns3_nic_get_stats64(struct net_device *ndev, struct
> rtnl_link_stats64 *stats)
> > +{
> > +	struct hns3_nic_priv *priv = netdev_priv(ndev);
> > +	int queue_num = priv->ae_handle->kinfo.num_tqps;
> > +	u64 tx_bytes = 0;
> > +	u64 rx_bytes = 0;
> > +	u64 tx_pkts = 0;
> > +	u64 rx_pkts = 0;
> > +	int idx = 0;
> unnecessary initialization
> 
> > +
> > +	for (idx = 0; idx < queue_num; idx++) {
> > +		tx_bytes += priv->ring_data[idx].ring->stats.tx_bytes;
> > +		tx_pkts += priv->ring_data[idx].ring->stats.tx_pkts;
> > +		rx_bytes +=
> > +			priv->ring_data[idx + queue_num].ring-
> >stats.rx_bytes;
> > +		rx_pkts += priv->ring_data[idx + queue_num].ring-
> >stats.rx_pkts;
> > +	}
> > +
> 
> Since rx_bytes and other statistics are 64 bit values. You need to use
> something to ensure that updates to these values are atomic on 32 bit
> platforms.  The most common way to handle this is with the
> u64_stats_sync
> mechanism which is a nop on 64 bit architectures, and uses a seqcount
> to do updates on 32 bit CPU's.
Sure good point. This has changed in the V4 patch.

Thanks for guiding.
Salil

> 
> 
