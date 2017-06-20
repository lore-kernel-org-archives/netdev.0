From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH NET] net/hns:bugfix of ethtool -t phy self_test
Date: Tue, 20 Jun 2017 15:27:05 +0200
Message-ID: <20170620132705.GD13704@lunn.ch>
References: <1497605091-94725-1-git-send-email-linyunsheng@huawei.com>
 <7500513f-e263-838c-12a1-4343f7281f1a@gmail.com>
 <08ef77fc-29ab-8262-2126-c547960d5628@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Florian Fainelli <f.fainelli@gmail.com>, davem@davemloft.net,
        huangdaode@hisilicon.com, xuwei5@hisilicon.com,
        liguozhu@hisilicon.com, Yisen.Zhuang@huawei.com,
        gabriele.paoloni@huawei.com, john.garry@huawei.com,
        linuxarm@huawei.com, salil.mehta@huawei.com, lipeng321@huawei.com,
        yankejian@huawei.com, tremyfr@gmail.com, xieqianqian@huawei.com,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: l00371289 <linyunsheng@huawei.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <08ef77fc-29ab-8262-2126-c547960d5628@huawei.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Jun 20, 2017 at 11:05:54AM +0800, l00371289 wrote:
> hi, Florian
> 
> On 2017/6/20 5:00, Florian Fainelli wrote:
> > On 06/16/2017 02:24 AM, Lin Yun Sheng wrote:
> >> This patch fixes the phy loopback self_test failed issue. when
> >> Marvell Phy Module is loaded, it will powerdown fiber when doing
> >> phy loopback self test, which cause phy loopback self_test fail.
> >>
> >> Signed-off-by: Lin Yun Sheng <linyunsheng@huawei.com>
> >> ---
> >>  drivers/net/ethernet/hisilicon/hns/hns_ethtool.c | 16 ++++++++++++++--
> >>  1 file changed, 14 insertions(+), 2 deletions(-)
> >>
> >> diff --git a/drivers/net/ethernet/hisilicon/hns/hns_ethtool.c b/drivers/net/ethernet/hisilicon/hns/hns_ethtool.c
> >> index b8fab14..e95795b 100644
> >> --- a/drivers/net/ethernet/hisilicon/hns/hns_ethtool.c
> >> +++ b/drivers/net/ethernet/hisilicon/hns/hns_ethtool.c
> >> @@ -288,9 +288,15 @@ static int hns_nic_config_phy_loopback(struct phy_device *phy_dev, u8 en)
> > 
> > The question really is, why is not this properly integrated into the PHY
> > driver and PHYLIB such that the only thing the Ethernet MAC driver has
> > to call is a function of the PHY driver putting it in self-test?
> Do you meaning calling phy_dev->drv->resume and phy_dev->drv->suspend function?

No. Florian is saying you should add support for phylib and the
drivers to enable/disable loopback.

The BMCR loopback bit is pretty much standardised. So you can
implement a genphy_loopback(phydev, enable), which most drivers can
use. Those that need there own can implement it in there driver.

     Andrew
