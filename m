From: Yangbo Lu <yangbo.lu@nxp.com>
Subject: RE: [v6, 5/5] mmc: sdhci-of-esdhc: fix host version for
 T4240-R1.0-R2.0
Date: Fri, 25 Mar 2016 06:43:24 +0000
Message-ID: <HE1PR04MB08899E1161ADC80A455B7401F8830@HE1PR04MB0889.eurprd04.prod.outlook.com>
References: <1457518131-11339-1-git-send-email-yangbo.lu@nxp.com>
 <DB5PR0401MB19286B2D23D07F5C60DB799D91880@DB5PR0401MB1928.eurprd04.prod.outlook.com>
 <20160317170101.GA21009@rob-hp-laptop> <3706958.XeRFmKM0K5@wuerfel>
 <DB5PR0401MB1928DA88B03970E1EACFB1FF918C0@DB5PR0401MB1928.eurprd04.prod.outlook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "linuxppc-dev@lists.ozlabs.org" <linuxppc-dev@lists.ozlabs.org>,
	"devicetree@vger.kernel.org" <devicetree@vger.kernel.org>,
	"ulf.hansson@linaro.org" <ulf.hansson@linaro.org>,
	Zhao Qiang <qiang.zhao@freescale.com>,
	Russell King <linux@arm.linux.org.uk>,
	"Bhupesh Sharma" <bhupesh.sharma@freescale.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Joerg Roedel <joro@8bytes.org>,
	Kumar Gala <galak@codeaurora.org>,
	"linux-mmc@vger.kernel.org" <linux-mmc@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	Yang-Leo Li <leoyang.li@nxp.com>,
	"iommu@lists.linux-foundation.org" <iommu@lists.linux-foundation.org>,
	"linux-i2c@vger.kernel.org" <linux-i2c@vger.kernel.org>,
	Claudiu Manoil <claudiu.manoil@freescale.com>,
	Santosh Shilimkar <ssantosh@kernel.org>,
	Xiaobo Xie <xiaobo.xie@nxp.com>,
	"linux-clk@vger.kernel.org" <linux-clk@vger.kernel.org>,
To: Scott Wood <scott.wood@nxp.com>, Arnd Bergmann <arnd@arndb.de>,
	"Rob Herring" <robh@kernel.org>
Return-path: <linux-i2c-owner@vger.kernel.org>
In-Reply-To: <DB5PR0401MB1928DA88B03970E1EACFB1FF918C0@DB5PR0401MB1928.eurprd04.prod.outlook.com>
Content-Language: en-US
Sender: linux-i2c-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> -----Original Message-----
> From: Scott Wood
> Sent: Saturday, March 19, 2016 2:28 AM
> To: Arnd Bergmann; Rob Herring
> Cc: Yangbo Lu; linuxppc-dev@lists.ozlabs.org; devicetree@vger.kernel.org;
> ulf.hansson@linaro.org; Zhao Qiang; Russell King; Bhupesh Sharma;
> netdev@vger.kernel.org; Joerg Roedel; Kumar Gala; linux-
> mmc@vger.kernel.org; linux-kernel@vger.kernel.org; Yang-Leo Li;
> iommu@lists.linux-foundation.org; linux-i2c@vger.kernel.org; Claudiu
> Manoil; Santosh Shilimkar; Xiaobo Xie; linux-clk@vger.kernel.org; linux-
> arm-kernel@lists.infradead.org
> Subject: Re: [v6, 5/5] mmc: sdhci-of-esdhc: fix host version for T4240-
> R1.0-R2.0
> 
> On 03/17/2016 12:06 PM, Arnd Bergmann wrote:
> > On Thursday 17 March 2016 12:01:01 Rob Herring wrote:
> >> On Mon, Mar 14, 2016 at 05:45:43PM +0000, Scott Wood wrote:
> >
> >>>>> This makes the driver non-portable. Better identify the specific
> >>>>> workarounds based on the compatible string for this device, or add
> >>>>> a boolean DT property for the quirk.
> >>>>>
> >>>>>    Arnd
> >>>>
> >>>> [Lu Yangbo-B47093] Hi Arnd, we did have a discussion about using DTS
> in v1 before.
> >>>> https://patchwork.kernel.org/patch/6834221/
> >>>>
> >>>> We don't have a separate DTS file for each revision of an SOC and if
> we did, we'd constantly have people using the wrong one.
> >>>> In addition, the device tree is stable ABI and errata are often
> discovered after device tree are deployed.
> >>>> See the link for details.
> >>>>
> >>>> So we decide to read SVR from the device-config/guts MMIO block
> other than using DTS.
> >>>> Thanks.
> >>>
> >>> Also note that this driver is already only for fsl-specific
> >>> hardware, and it will still work even if fsl_guts doesn't find
> >>> anything to bind to
> >>> -- it just wouldn't be able to detect errata based on SVR in that
> case.
> >>
> >> IIRC, it is the same IP block as i.MX and Arnd's point is this won't
> >> even compile on !PPC. It is things like this that prevent sharing the
> >> driver.
> 
> The whole point of using the MMIO SVR instead of the PPC SPR is so that
> it will work on ARM...  The guts driver should build on any platform as
> long as OF is enabled, and if it doesn't find a node to bind to it will
> return 0 for SVR, and the eSDHC driver will continue (after printing an
> error that should be removed) without the ability to test for errata
> based on SVR.
> 
> > I think the first four patches take care of building for ARM, but the
> > problem remains if you want to enable COMPILE_TEST as we need for
> > certain automated checking.
> 
> What specific problem is there with COMPILE_TEST?
> 
> >> Dealing with Si revs is a common problem. We should have a common
> >> solution. There is soc_device for this purpose.
> >
> > Exactly. The last time this came up, I think we agreed to implement a
> > helper using glob_match() on the soc_device strings. Unfortunately
> > this hasn't happened then, but I'd still prefer that over yet another
> > vendor-specific way of dealing with the generic issue.
> 
> soc_device would require encoding the SVR as a string and then decoding
> the string, which is more complicated and error prone than having
> platform-specific code test a platform-specific number.  And when would
> it get registered on arm64, which doesn't have platform code?
> 
> -Scott

[Lu Yangbo-B47093] Hi Arnd, could you answer Scott's questions?
If you don't oppose this patch, I'd like to rework a new version for merging.
Thanks.

:)
