From: Salil Mehta <salil.mehta@huawei.com>
Subject: RE: [PATCH V2 net-next 1/8] net: hns3: Add support of HNS3 Ethernet
 Driver for hip08 SoC
Date: Sat, 17 Jun 2017 10:47:43 +0000
Message-ID: <F4CC6FACFEB3C54C9141D49AD221F7F93B7B2BE1@FRAEML521-MBS.china.huawei.com>
References: <20170613231035.494020-1-salil.mehta@huawei.com>
        <20170613231035.494020-2-salil.mehta@huawei.com>
 <20170613165303.7a096821@xeon-e3>
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
In-Reply-To: <20170613165303.7a096821@xeon-e3>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Stephen

> -----Original Message-----
> From: Stephen Hemminger [mailto:stephen@networkplumber.org]
> Sent: Wednesday, June 14, 2017 12:53 AM
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
> > +static irqreturn_t hns3_irq_handle(int irq, void *dev)
> > +{
> > +	struct hns3_enet_tqp_vector *tqp_vector = dev;
> > +
> > +	napi_schedule(&tqp_vector->napi);
> 
> In order to do NAPI correctly, the IRQ must be disabled.
> If you are using MSI, then hardware will do it for you.
Yes, you are correct. They get auto disabled in our case.

> 
> But I don't see you ever enable MSI or MSI-x in this driver.

We are enabling them again in common poll:

static int hns3_nic_common_poll(struct napi_struct *napi, int budget)
{
	struct hns3_enet_ring *ring;
	int rx_pkt_total = 0;

      [....]

	hns3_mask_vector_irq(tqp_vector, 1);---> this re-enables the interrupts on NIC.

	return rx_pkt_total;
}

> Are you just assuming that the driver only works on one platform
> and that platform has PCI MSI-X?
We support both MSI and MSI-X. Hope I answered this completely?

Best regards
Salil
