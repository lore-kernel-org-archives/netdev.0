From: =?utf-8?B?U8O2cmVu?= Brinkmann <soren.brinkmann@xilinx.com>
Subject: Re: [PATCH v2] can: Fix bug in suspend/resume
Date: Fri, 14 Nov 2014 07:20:23 -0800
Message-ID: <8d29d376aa02429dabd754b505fb336d@BN1BFFO11FD041.protection.gbl>
References: <e7070431858e49e29cd03d76fd7a66c3@BN1AFFO11FD055.protection.gbl>
 <5465C34D.4030805@pengutronix.de>
 <e5f5913b51a54222aa1bb0680a77e56d@BN1AFFO11FD055.protection.gbl>
 <54661B2F.2000704@pengutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Kedareswara rao Appana <appana.durga.rao@xilinx.com>,
	<wg@grandegger.com>, <michal.simek@xilinx.com>,
	<grant.likely@linaro.org>, <robh+dt@kernel.org>,
	<linux-can@vger.kernel.org>, <netdev@vger.kernel.org>,
	<linux-arm-kernel@lists.infradead.org>,
	<linux-kernel@vger.kernel.org>, <devicetree@vger.kernel.org>,
	Kedareswara rao Appana <appanad@xilinx.com>
To: Marc Kleine-Budde <mkl@pengutronix.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <54661B2F.2000704@pengutronix.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 2014-11-14 at 04:09PM +0100, Marc Kleine-Budde wrote:
> On 11/14/2014 04:05 PM, S=C3=B6ren Brinkmann wrote:
> > On Fri, 2014-11-14 at 09:54AM +0100, Marc Kleine-Budde wrote:
> >> On 11/14/2014 09:16 AM, Kedareswara rao Appana wrote:
> >>> The drvdata in the suspend/resume is of type struct net_device,
> >>> not the platform device.Enable the clocks in the suspend before
> >>> accessing the registers of the CAN.
> >>>
> >>> Signed-off-by: Kedareswara rao Appana <appanad@xilinx.com>
> >>> ---
> >>> Changes for v2:
> >>>   - Removed the struct platform_device* from suspend/resume
> >>>     as suggest by Lothar.
> >>>   - The clocks are getting disabled and un prepared at the end of=
 the probe.=20
> >>>     In the suspend the driver is doing a register write.In order
> >>>     To do that register write we have to again enable and prepare=
 the clocks.
> >>
> >> Please look the at suspend/resume code and count the
> >> clock_enable/disable manually. After a suspend/resume cycle, you h=
ave
> >> enabled the clock twice, but disabled it once.
> >>
> >> I think you have to abstract the clock handling behind runtime PM.=
 I
> >> haven't done this myself yet, but the strong feeling that this is =
a
> >> possible solution to your problem. These links might help:
> >=20
> > I agree, the clock handling looks weird. Also the clk_disable calls=
 in
> > xcan_get_berr_counter() look suspicious to me, but I might be wrong=
=2E
> > I think you can take a look at gpio-zynq for an example for runtime=
_pm
> > usage. I think the usage model in that driver is similar to here.
>=20
> The xcan_get_berr_counter() function is correct, when doing manual (i=
=2Ee.
> non runtime-pm) clock handling. This function might be called if the
> interface is down, this means clocks are disabled.

I see, thanks for the clarification. Guess that should become
pm_runtime_get_sync() and pm_runtime_put() when converting to
runtime_pm.

	S=C3=B6ren
