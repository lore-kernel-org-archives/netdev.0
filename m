From: =?utf-8?B?U8O2cmVu?= Brinkmann <soren.brinkmann@xilinx.com>
Subject: Re: [PATCH] net: can: Enable xilinx driver for all ARCHs
Date: Mon, 9 Mar 2015 08:51:47 -0700
Message-ID: <BY2FFO11FD0539B08FEA25A4338C347898C1B0@BY2FFO11FD053.protection.gbl>
References: <4096fa4ceae72817d8e64d9a1da738038a5c864a.1425890926.git.michal.simek@xilinx.com>
 <54FD5EE1.6050402@pengutronix.de>
 <BY2FFO11FD001BD9CFD92C94214501BB8E21B0@BY2FFO11FD001.protection.gbl>
 <54FD641C.7090607@pengutronix.de>
 <BY2FFO11FD0060B11FE9C9305D5DFD12BE21B0@BY2FFO11FD006.protection.gbl>
 <54FD6E42.6070206@pengutronix.de> <1425909239.23920.60.camel@chaos.site>
 <54FDA662.8020801@pengutronix.de>
 <BY2FFO11FD023D29C02DAF9CCBDC40386E21B0@BY2FFO11FD023.protection.gbl>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Marc Kleine-Budde <mkl@pengutronix.de>,
	Jean Delvare <jdelvare@suse.de>,
	<linux-kernel@vger.kernel.org>, <monstr@monstr.eu>,
	Wolfgang Grandegger <wg@grandegger.com>,
	<linux-can@vger.kernel.org>, <netdev@vger.kernel.org>
To: Michal Simek <michal.simek@xilinx.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <BY2FFO11FD023D29C02DAF9CCBDC40386E21B0@BY2FFO11FD023.protection.gbl>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2015-03-09 at 03:04PM +0100, Michal Simek wrote:
> On 03/09/2015 02:55 PM, Marc Kleine-Budde wrote:
> > On 03/09/2015 02:53 PM, Jean Delvare wrote:
> >> Le Monday 09 March 2015 =C3=A0 10:56 +0100, Marc Kleine-Budde a =C3=
=A9crit :
> >>> On 03/09/2015 10:52 AM, Michal Simek wrote:
> >>>> On 03/09/2015 10:13 AM, Marc Kleine-Budde wrote:
> >>>>> On 03/09/2015 09:58 AM, Michal Simek wrote:
> >>>>>> On 03/09/2015 09:50 AM, Marc Kleine-Budde wrote:
> >>>>>>> On 03/09/2015 09:48 AM, Michal Simek wrote:
> >>>>>>>> Remove Kconfig dependency and enable driver for
> >>>>>>>> all ARCHs.
> >>>>>>>>
> >>>>>>>> Signed-off-by: Michal Simek <michal.simek@xilinx.com>
> >>>>>>>> Acked-by: S=C3=B6ren Brinkmann <soren.brinkmann@xilinx.com>
> >>>>>>>> ---
> >>>>>>>>
> >>>>>>>> Test for all archs done by Kbuild test robot without any pro=
blem.
> >>>>>>>> ---
> >>>>>>>>  drivers/net/can/Kconfig | 1 -
> >>>>>>>>  1 file changed, 1 deletion(-)
> >>>>>>>>
> >>>>>>>> diff --git a/drivers/net/can/Kconfig b/drivers/net/can/Kconf=
ig
> >>>>>>>> index 98d73aab52fe..f690c3fb3088 100644
> >>>>>>>> --- a/drivers/net/can/Kconfig
> >>>>>>>> +++ b/drivers/net/can/Kconfig
> >>>>>>>> @@ -131,7 +131,6 @@ config CAN_RCAR
> >>>>>>>> =20
> >>>>>>>>  config CAN_XILINXCAN
> >>>>>>>>  	tristate "Xilinx CAN"
> >>>>>>>> -	depends on ARCH_ZYNQ || MICROBLAZE || COMPILE_TEST
> >>>>>>>
> >>>>>>> I think that's what COMPILE_TEST ist for?
> >>>>>>
> >>>>>> For compilation yes but not for enabling. Currently this drive=
r
> >>>>>> can be also used on ARM64 that's why people suggesting directl=
y
> >>>>>> to remove dependency on arch and then COMPILE_TEST can be remo=
ved
> >>>>>> too.
> >>>>>
> >>>>> In the past (May 2014) I had people complaining that certain AR=
M SoC
> >>>>> specific drivers are enabled on ARM in general, not just on tha=
t SoC. As
> >>>>> I'm not following arm64 in detail, has the notion of using depe=
nds on
> >>>>> ARCH changes since then?
> >>>>>
> >>>>>> Or do you want me to change description to mention that this i=
s for
> >>>>>> ARM64 enabling?
> >>>>>
> >>>>> Given this is consensus, a remark to ARM64 would be appreciated=
=2E :)
> >>>>
> >>>> David has applied this patch which is in general just the same a=
s this one.
> >>>>
> >>>> (linux-next) Remove architecture dependency
> >>>> 28811a8c00fe0d899b8a544421f3b4947425d5e8
> >>>>
> >>>> Mark Brown has suggested to do so for spi and don't check archit=
ecture at
> >>>> all.
> >>>> I have also sent similar patch for watchdog driver too.
> >>>>
> >>>> I think it is up to you if you want to add ARM64 to Kconfig or j=
ust remove
> >>>> that arch dependencies.
> >>>> To be honest my goal is to enable this driver for ARM64.
> >>>> Please tell me what way you prefer.
> >>>
> >>> I like the idea of removing the depends on ARCH completely. Jean,=
 what
> >>> do you think?
> >>
> >> Removing the dependency completely will let the option be displaye=
d on
> >> systems where the driver is useless. I am in favor of having hardw=
are
> >> dependencies on as many drivers as possible to avoid bothering the=
 user
> >> with irrelevant questions. The list of Kconfig entries has grown a=
 lot
> >> over time!
> >>
> >> If the current dependency is too strict then I would suggest to ex=
tend
> >> it or to make it broader (depends on ARM || ARM64 || COMPILE_TEST =
would
> >> be acceptable IMHO.) Dropping it completely only makes sense if th=
e part
> >> is used on so many systems that the dependency becomes too long or=
 is a
> >> pain to maintain.
> >=20
> > Sounds reasonable. Michael, make it so.
>=20
> I have sent v2 which add arm64 to Kconfig and I am keeping just depen=
dency on
> ARCH_ZYNQ not all ARM platforms.

You could (and some people do that with some devices) use these devices
from x86(_64) if you plug your FPGA/Zynq platform into a PCIe slot
(FWIW, this should work for any platform that supports PCIe). I think w=
e
just had somebody sending patches to enable the Zynq UART, IIRC, for x8=
6.

	S=C3=B6ren
