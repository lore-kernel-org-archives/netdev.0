From: Jean Delvare <jdelvare@suse.de>
Subject: Re: [PATCH] net: can: Enable xilinx driver for all ARCHs
Date: Mon, 09 Mar 2015 14:53:59 +0100
Message-ID: <1425909239.23920.60.camel@chaos.site>
References: <4096fa4ceae72817d8e64d9a1da738038a5c864a.1425890926.git.michal.simek@xilinx.com>
	 <54FD5EE1.6050402@pengutronix.de>
	 <BY2FFO11FD001BD9CFD92C94214501BB8E21B0@BY2FFO11FD001.protection.gbl>
	 <54FD641C.7090607@pengutronix.de>
	 <BY2FFO11FD0060B11FE9C9305D5DFD12BE21B0@BY2FFO11FD006.protection.gbl>
	 <54FD6E42.6070206@pengutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Michal Simek <michal.simek@xilinx.com>,
	linux-kernel@vger.kernel.org, monstr@monstr.eu,
	Wolfgang Grandegger <wg@grandegger.com>,
	linux-can@vger.kernel.org, netdev@vger.kernel.org
To: Marc Kleine-Budde <mkl@pengutronix.de>
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <54FD6E42.6070206@pengutronix.de>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le Monday 09 March 2015 =C3=A0 10:56 +0100, Marc Kleine-Budde a =C3=A9c=
rit :
> On 03/09/2015 10:52 AM, Michal Simek wrote:
> > On 03/09/2015 10:13 AM, Marc Kleine-Budde wrote:
> >> On 03/09/2015 09:58 AM, Michal Simek wrote:
> >>> On 03/09/2015 09:50 AM, Marc Kleine-Budde wrote:
> >>>> On 03/09/2015 09:48 AM, Michal Simek wrote:
> >>>>> Remove Kconfig dependency and enable driver for
> >>>>> all ARCHs.
> >>>>>
> >>>>> Signed-off-by: Michal Simek <michal.simek@xilinx.com>
> >>>>> Acked-by: S=C3=B6ren Brinkmann <soren.brinkmann@xilinx.com>
> >>>>> ---
> >>>>>
> >>>>> Test for all archs done by Kbuild test robot without any proble=
m.
> >>>>> ---
> >>>>>  drivers/net/can/Kconfig | 1 -
> >>>>>  1 file changed, 1 deletion(-)
> >>>>>
> >>>>> diff --git a/drivers/net/can/Kconfig b/drivers/net/can/Kconfig
> >>>>> index 98d73aab52fe..f690c3fb3088 100644
> >>>>> --- a/drivers/net/can/Kconfig
> >>>>> +++ b/drivers/net/can/Kconfig
> >>>>> @@ -131,7 +131,6 @@ config CAN_RCAR
> >>>>> =20
> >>>>>  config CAN_XILINXCAN
> >>>>>  	tristate "Xilinx CAN"
> >>>>> -	depends on ARCH_ZYNQ || MICROBLAZE || COMPILE_TEST
> >>>>
> >>>> I think that's what COMPILE_TEST ist for?
> >>>
> >>> For compilation yes but not for enabling. Currently this driver
> >>> can be also used on ARM64 that's why people suggesting directly
> >>> to remove dependency on arch and then COMPILE_TEST can be removed
> >>> too.
> >>
> >> In the past (May 2014) I had people complaining that certain ARM S=
oC
> >> specific drivers are enabled on ARM in general, not just on that S=
oC. As
> >> I'm not following arm64 in detail, has the notion of using depends=
 on
> >> ARCH changes since then?
> >>
> >>> Or do you want me to change description to mention that this is f=
or
> >>> ARM64 enabling?
> >>
> >> Given this is consensus, a remark to ARM64 would be appreciated. :=
)
> >=20
> > David has applied this patch which is in general just the same as t=
his one.
> >=20
> > (linux-next) Remove architecture dependency
> > 28811a8c00fe0d899b8a544421f3b4947425d5e8
> >=20
> > Mark Brown has suggested to do so for spi and don't check architect=
ure at
> > all.
> > I have also sent similar patch for watchdog driver too.
> >=20
> > I think it is up to you if you want to add ARM64 to Kconfig or just=
 remove
> > that arch dependencies.
> > To be honest my goal is to enable this driver for ARM64.
> > Please tell me what way you prefer.
>=20
> I like the idea of removing the depends on ARCH completely. Jean, wha=
t
> do you think?

Removing the dependency completely will let the option be displayed on
systems where the driver is useless. I am in favor of having hardware
dependencies on as many drivers as possible to avoid bothering the user
with irrelevant questions. The list of Kconfig entries has grown a lot
over time!

If the current dependency is too strict then I would suggest to extend
it or to make it broader (depends on ARM || ARM64 || COMPILE_TEST would
be acceptable IMHO.) Dropping it completely only makes sense if the par=
t
is used on so many systems that the dependency becomes too long or is a
pain to maintain.

Thanks,
--=20
Jean Delvare
SUSE L3 Support

