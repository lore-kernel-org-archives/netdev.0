From: Scott Wood <scott.wood@nxp.com>
Subject: Re: [v6, 5/5] mmc: sdhci-of-esdhc: fix host version for
 T4240-R1.0-R2.0
Date: Fri, 18 Mar 2016 18:28:05 +0000
Message-ID: <DB5PR0401MB1928DA88B03970E1EACFB1FF918C0@DB5PR0401MB1928.eurprd04.prod.outlook.com>
References: <1457518131-11339-1-git-send-email-yangbo.lu@nxp.com>
 <DB5PR0401MB19286B2D23D07F5C60DB799D91880@DB5PR0401MB1928.eurprd04.prod.outlook.com>
 <20160317170101.GA21009@rob-hp-laptop> <3706958.XeRFmKM0K5@wuerfel>
Mime-Version: 1.0
Content-Type: text/plain; charset=Windows-1252
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Yangbo Lu <yangbo.lu@nxp.com>,
	"linuxppc-dev@lists.ozlabs.org" <linuxppc-dev@lists.ozlabs.org>,
	"devicetree@vger.kernel.org" <devicetree@vger.kernel.org>,
	"ulf.hansson@linaro.org" <ulf.hansson@linaro.org>,
	Zhao Qiang <qiang.zhao@freescale.com>,
	Russell King <linux@arm.linux.org.uk>,
	Bhupesh Sharma <bhupesh.sharma@freescale.com>,
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
	"linux-clk@vger.kernel.org
To: Arnd Bergmann <arnd@arndb.de>, Rob Herring <robh@kernel.org>
Return-path: <linux-clk-owner@vger.kernel.org>
Content-Language: en-US
Sender: linux-clk-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 03/17/2016 12:06 PM, Arnd Bergmann wrote:
> On Thursday 17 March 2016 12:01:01 Rob Herring wrote:
>> On Mon, Mar 14, 2016 at 05:45:43PM +0000, Scott Wood wrote:
>=20
>>>>> This makes the driver non-portable. Better identify the specific
>>>>> workarounds based on the compatible string for this device, or ad=
d a
>>>>> boolean DT property for the quirk.
>>>>>
>>>>>    Arnd
>>>>
>>>> [Lu Yangbo-B47093] Hi Arnd, we did have a discussion about using D=
TS in v1 before.
>>>> https://patchwork.kernel.org/patch/6834221/
>>>>
>>>> We don=92t have a separate DTS file for each revision of an SOC an=
d if we did, we'd constantly have people using the wrong one.
>>>> In addition, the device tree is stable ABI and errata are often di=
scovered after device tree are deployed.
>>>> See the link for details.
>>>>
>>>> So we decide to read SVR from the device-config/guts MMIO block ot=
her than using DTS.
>>>> Thanks.
>>>
>>> Also note that this driver is already only for fsl-specific hardwar=
e,
>>> and it will still work even if fsl_guts doesn't find anything to bi=
nd to
>>> -- it just wouldn't be able to detect errata based on SVR in that c=
ase.
>>
>> IIRC, it is the same IP block as i.MX and Arnd's point is this won't=
=20
>> even compile on !PPC. It is things like this that prevent sharing th=
e=20
>> driver.

The whole point of using the MMIO SVR instead of the PPC SPR is so that
it will work on ARM...  The guts driver should build on any platform as
long as OF is enabled, and if it doesn't find a node to bind to it will
return 0 for SVR, and the eSDHC driver will continue (after printing an
error that should be removed) without the ability to test for errata
based on SVR.

> I think the first four patches take care of building for ARM,
> but the problem remains if you want to enable COMPILE_TEST as
> we need for certain automated checking.

What specific problem is there with COMPILE_TEST?

>> Dealing with Si revs is a common problem. We should have a=20
>> common solution. There is soc_device for this purpose.
>=20
> Exactly. The last time this came up, I think we agreed to implement a
> helper using glob_match() on the soc_device strings. Unfortunately
> this hasn't happened then, but I'd still prefer that over yet another
> vendor-specific way of dealing with the generic issue.

soc_device would require encoding the SVR as a string and then decoding
the string, which is more complicated and error prone than having
platform-specific code test a platform-specific number.  And when would
it get registered on arm64, which doesn't have platform code?

-Scott

