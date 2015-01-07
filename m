From: =?utf-8?B?U8O2cmVu?= Brinkmann <soren.brinkmann@xilinx.com>
Subject: Re: [PATCH v4] can: Convert to runtime_pm
Date: Wed, 7 Jan 2015 08:32:48 -0800
Message-ID: <1d3216d75e9d494fb68ce9a3b24e7ca3@BL2FFO11FD017.protection.gbl>
References: <58f37b6fd9104ce185c413c473fe047b@BY2FFO11FD050.protection.gbl>
 <54AD267C.4060004@pengutronix.de>
 <a868331b44ce4b2a80b572399530f1f9@BN1BFFO11FD043.protection.gbl>
 <54AD5F13.1020107@pengutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Kedareswara rao Appana <appana.durga.rao@xilinx.com>,
	<wg@grandegger.com>, <michal.simek@xilinx.com>,
	<grant.likely@linaro.org>, <linux-can@vger.kernel.org>,
	<netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
	Kedareswara rao Appana <appanad@xilinx.com>
To: Marc Kleine-Budde <mkl@pengutronix.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <54AD5F13.1020107@pengutronix.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2015-01-07 at 05:30PM +0100, Marc Kleine-Budde wrote:
> On 01/07/2015 04:58 PM, S=C3=B6ren Brinkmann wrote:
> >> I think you have to convert the _remove() function, too. Have a lo=
ok at
> >> the gpio-zynq.c driver:
> >>
> >>> static int zynq_gpio_remove(struct platform_device *pdev)
> >>> {
> >>> 	struct zynq_gpio *gpio =3D platform_get_drvdata(pdev);
> >>>
> >>> 	pm_runtime_get_sync(&pdev->dev);
> >>
> >> However I don't understand why the get_sync() is here. Maybe S=C3=B6=
ren can help?
> >=20
> > IIRC, the concern was that the remove function may be called while =
the device is
> > runtime suspended. Hence the remove function needs to resume the de=
vice since the
> > remove function may access the HW.
>=20
> What about the corresponding runtime_put()? Would some counter be
> unbalanced upon device removal?

Aren't those counters destroyed with module unloading?

	S=C3=B6ren
