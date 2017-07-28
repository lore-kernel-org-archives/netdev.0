From: Salil Mehta <salil.mehta@huawei.com>
Subject: RE: [PATCH V4 net-next 2/8] net: hns3: Add support of the HNAE3
 framework
Date: Fri, 28 Jul 2017 11:52:38 +0000
Message-ID: <F4CC6FACFEB3C54C9141D49AD221F7F93B829568@FRAEML521-MBX.china.huawei.com>
References: <20170722220942.78852-1-salil.mehta@huawei.com>
 <20170722220942.78852-3-salil.mehta@huawei.com>
 <20170723131530.GJ3259@mtr-leonro.local>
 <F4CC6FACFEB3C54C9141D49AD221F7F93B828A12@FRAEML521-MBX.china.huawei.com>
 <20170728044137.GF13672@mtr-leonro.local>
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
        "linux-rdma@vger.kernel.org" <linux-rdma@vger.kernel.org>,
        Linuxarm <linuxarm@huawei.com>
To: Leon Romanovsky <leon@kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170728044137.GF13672@mtr-leonro.local>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Leon,

> -----Original Message-----
> From: linux-rdma-owner@vger.kernel.org [mailto:linux-rdma-
> owner@vger.kernel.org] On Behalf Of Leon Romanovsky
> Sent: Friday, July 28, 2017 5:42 AM
> To: Salil Mehta
> Cc: davem@davemloft.net; Zhuangyuzeng (Yisen); huangdaode; lipeng (Y);
> mehta.salil.lnk@gmail.com; netdev@vger.kernel.org; linux-
> kernel@vger.kernel.org; linux-rdma@vger.kernel.org; Linuxarm
> Subject: Re: [PATCH V4 net-next 2/8] net: hns3: Add support of the
> HNAE3 framework
> 
> On Thu, Jul 27, 2017 at 11:44:32PM +0000, Salil Mehta wrote:
> > Hi Leon
> >
> > > -----Original Message-----
> > > From: linux-rdma-owner@vger.kernel.org [mailto:linux-rdma-
> > > owner@vger.kernel.org] On Behalf Of Leon Romanovsky
> > > Sent: Sunday, July 23, 2017 2:16 PM
> > > To: Salil Mehta
> > > Cc: davem@davemloft.net; Zhuangyuzeng (Yisen); huangdaode; lipeng
> (Y);
> > > mehta.salil.lnk@gmail.com; netdev@vger.kernel.org; linux-
> > > kernel@vger.kernel.org; linux-rdma@vger.kernel.org; Linuxarm
> > > Subject: Re: [PATCH V4 net-next 2/8] net: hns3: Add support of the
> > > HNAE3 framework
> > >
> > > On Sat, Jul 22, 2017 at 11:09:36PM +0100, Salil Mehta wrote:
> > > > This patch adds the support of the HNAE3 (Hisilicon Network
> > > > Acceleration Engine 3) framework support to the HNS3 driver.
> > > >
> > > > Framework facilitates clients like ENET(HNS3 Ethernet Driver),
> RoCE
> > > > and user-space Ethernet drivers (like ODP etc.) to register with
> > > HNAE3
> > > > devices and their associated operations.
> > > >
> > > > Signed-off-by: Daode Huang <huangdaode@hisilicon.com>
> > > > Signed-off-by: lipeng <lipeng321@huawei.com>
> > > > Signed-off-by: Salil Mehta <salil.mehta@huawei.com>
> > > > Signed-off-by: Yisen Zhuang <yisen.zhuang@huawei.com>
> > > > ---
> > > > Patch V4: Addressed following comments
> > > >   1. Andrew Lunn:
> > > >      https://lkml.org/lkml/2017/6/17/233
> > > >      https://lkml.org/lkml/2017/6/18/105
> > > >   2. Bo Yu:
> > > >      https://lkml.org/lkml/2017/6/18/112
> > > >   3. Stephen Hamminger:
> > > >      https://lkml.org/lkml/2017/6/19/778
> > > > Patch V3: Addressed below comments
> > > >   1. Andrew Lunn:
> > > >      https://lkml.org/lkml/2017/6/13/1025
> > > > Patch V2: No change
> > > > Patch V1: Initial Submit
> > > > ---
> > > >  drivers/net/ethernet/hisilicon/hns3/hnae3.c | 319
> > > ++++++++++++++++++++
> > > >  drivers/net/ethernet/hisilicon/hns3/hnae3.h | 449
> > > ++++++++++++++++++++++++++++
> > > >  2 files changed, 768 insertions(+)
> > > >  create mode 100644 drivers/net/ethernet/hisilicon/hns3/hnae3.c
> > > >  create mode 100644 drivers/net/ethernet/hisilicon/hns3/hnae3.h
> > > >
> > > > diff --git a/drivers/net/ethernet/hisilicon/hns3/hnae3.c
> > > b/drivers/net/ethernet/hisilicon/hns3/hnae3.c
> > > > new file mode 100644
> > > > index 000000000000..7a11aaff0a23

[...]

> > > > +
> > > > +#include <linux/acpi.h>
> > > > +#include <linux/delay.h>
> > > > +#include <linux/device.h>
> > > > +#include <linux/module.h>
> > > > +#include <linux/netdevice.h>
> > > > +#include <linux/pci.h>
> > > > +#include <linux/types.h>
> > > > +
> > > > +#define HNAE_DRIVER_VERSION "1.0"
> > >
> > > Please no driver versions.
> > We need this in ethtool. Most of the driver are using it.
> 
> So please, stop doing copy/paste and take a look how it was implemented
> in nfp.
> 
> Related discussion about useless of your driver version.
> https://lists.linuxfoundation.org/pipermail/ksummit-discuss/2017-
> June/004441.html
> https://lists.linuxfoundation.org/pipermail/ksummit-discuss/2017-
> June/004428.html
Sure, thanks for this. I will have a look 

> 
> >
> > >
> > > > +#define HNAE_DRIVER_NAME "hns3"
> > > > +#define HNAE_COPYRIGHT "Copyright(c) 2017 Huawei Corporation."
> > > > +#define HNAE_DRIVER_STRING "Hisilicon Network Subsystem Driver"
> > > > +#define HNAE_DEFAULT_DEVICE_DESCR "Hisilicon Network Subsystem"
> > >
> > > You are not subsystem yet.
> > Hisilicon Network System is the network related hardware within
> > Hip08 SoC of Hisilicon. This does not means HNS is Linux network
> > subsystem.
> 
> I understand it, so remove word "subsystem" and use more appropriate
> "core", "library", e.t.c
I understand this might look bit confusing, but if we change the name
of the driver now then we might have to change the name of the folders
and earlier driver names as well. Name of the earlier driver would be
very difficult to change at this stage since there might be people using
it.

Do you think if we rename to below it will bring more clarity?
+#define HNAE_DRIVER_STRING "Hisilicon Network Subsystem Ethernet Driver"
		OR
+#define HNAE_DRIVER_STRING "HNS3 Ethernet Driver"

Please suggest? Thanks!

Best regards
Salil
> 
> Thanks
