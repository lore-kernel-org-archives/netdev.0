From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH V2 net-next 1/8] net: hns3: Add support of HNS3 Ethernet
 Driver for hip08 SoC
Date: Tue, 13 Jun 2017 16:53:03 -0700
Message-ID: <20170613165303.7a096821@xeon-e3>
References: <20170613231035.494020-1-salil.mehta@huawei.com>
        <20170613231035.494020-2-salil.mehta@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: <davem@davemloft.net>, <yisen.zhuang@huawei.com>,
        <huangdaode@hisilicon.com>, <lipeng321@huawei.com>,
        <mehta.salil.lnk@gmail.com>, <netdev@vger.kernel.org>,
        <linux-kernel@vger.kernel.org>, <linuxarm@huawei.com>
To: Salil Mehta <salil.mehta@huawei.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170613231035.494020-2-salil.mehta@huawei.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 14 Jun 2017 00:10:28 +0100
Salil Mehta <salil.mehta@huawei.com> wrote:

> +static irqreturn_t hns3_irq_handle(int irq, void *dev)
> +{
> +	struct hns3_enet_tqp_vector *tqp_vector = dev;
> +
> +	napi_schedule(&tqp_vector->napi);

In order to do NAPI correctly, the IRQ must be disabled.
If you are using MSI, then hardware will do it for you.

But I don't see you ever enable MSI or MSI-x in this driver.
Are you just assuming that the driver only works on one platform
and that platform has PCI MSI-X?
