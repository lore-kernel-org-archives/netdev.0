From: Fugang Duan <fugang.duan@nxp.com>
Subject: RE: [PATCH v2 1/2] ARM: imx6: disable deeper idle states when FEC is
 active w/o HW workaround
Date: Mon, 13 Jun 2016 01:17:58 +0000
Message-ID: <VI1PR0401MB185520C3915ED81041902AF6FF530@VI1PR0401MB1855.eurprd04.prod.outlook.com>
References: <1464971480-9203-1-git-send-email-l.stach@pengutronix.de>
 <VI1PR0401MB1855AA40FA576AF677A68E6FFF5C0@VI1PR0401MB1855.eurprd04.prod.outlook.com>
 <1465464924.18807.5.camel@pengutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "devicetree@vger.kernel.org" <devicetree@vger.kernel.org>,
 "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
 "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>,
 "kernel@pengutronix.de" <kernel@pengutronix.de>,
 "patchwork-lst@pengutronix.de" <patchwork-lst@pengutronix.de>
To: Lucas Stach <l.stach@pengutronix.de>, Shawn Guo <shawnguo@kernel.org>
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
In-Reply-To: <1465464924.18807.5.camel@pengutronix.de>
Content-Language: en-US
List-Unsubscribe: <http://lists.infradead.org/mailman/options/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=unsubscribe>
List-Archive: <http://lists.infradead.org/pipermail/linux-arm-kernel/>
List-Post: <mailto:linux-arm-kernel@lists.infradead.org>
List-Help: <mailto:linux-arm-kernel-request@lists.infradead.org?subject=help>
List-Subscribe: <http://lists.infradead.org/mailman/listinfo/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=subscribe>
Sender: "linux-arm-kernel" <linux-arm-kernel-bounces@lists.infradead.org>
Errors-To: linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org
List-Id: netdev.vger.kernel.org

From: Lucas Stach <l.stach@pengutronix.de> Sent: Thursday, June 09, 2016 5:35 PM
> To: Fugang Duan <fugang.duan@nxp.com>; Shawn Guo <shawnguo@kernel.org>
> Cc: devicetree@vger.kernel.org; patchwork-lst@pengutronix.de;
> kernel@pengutronix.de; linux-arm-kernel@lists.infradead.org;
> netdev@vger.kernel.org
> Subject: Re: [PATCH v2 1/2] ARM: imx6: disable deeper idle states when FEC is
> active w/o HW workaround
> 
> Hi Fugang,
> 
> Am Montag, den 06.06.2016, 02:00 +0000 schrieb Fugang Duan:
> > From: Lucas Stach <l.stach@pengutronix.de> Sent: Saturday, June 04,
> > 2016 12:31 AM
> > >
> > > To: Shawn Guo <shawnguo@kernel.org>; Fugang Duan <fugang.duan@nxp.c
> > > om>
> > > Cc: devicetree@vger.kernel.org; patchwork-lst@pengutronix.de;
> > > kernel@pengutronix.de; linux-arm-kernel@lists.infradead.org;
> > > netdev@vger.kernel.org
> > > Subject: [PATCH v2 1/2] ARM: imx6: disable deeper idle states when
> > > FEC is active w/o HW workaround
> > >
> > > The i.MX6 Q/DL has an erratum (ERR006687) that prevents the FEC from
> > > waking the CPUs when they are in wait(unclocked) state. As the
> > > hardware workaround isn't applicable to all boards, disable the
> > > deeper idle state when the workaround isn't present and the FEC is
> > > in use.
> > >
> > > This allows to safely run a kernel with CPUidle enabled on all
> > > i.MX6 boards.
> > >
> > > Signed-off-by: Lucas Stach <l.stach@pengutronix.de>
> > > Acked-by: David S. Miller <davem@davemloft.net> (for network
> > > changes)
> > > ---
> 
> [...]
> 
> > Hi, Lucas,
> >
> > FEC irq cannot wake up CPUs when system is in wait mode. But we can
> > use GPIO_6 for FEC interrupt that GPIO irq wake up CPUs.
> > No need to disable wait mode as your such patches.
> >
> > You just config the gpio irq like below patches:
> > bc20a5d6da71 (ARM: dts: imx6qdl-sabreauto: use GPIO_6 for FEC
> > interrupt.)
> > 6261c4c8f13e (ARM: dts: imx6qdl-sabrelite: use GPIO_6 for FEC
> > interrupt.)
> >
> Please look at the description of this series again. The changes don't disable the
> deeper idle states on boards where the HW waorkaround is available. There is a
> large number of boards in the wild which can not use the HW workaround, as
> they use GPIO_6 for other purposes. The aim of this series is to have an
> automatic software workaround available for those boards.
> 
> Regards,
> Lucas

I see.  My concern is the wild boards why don't follow NXP HW reference guide.

For the patch itself, it is fine for me to fix the wild boards issue.

Acked-by: Fugang Duan <fugang.duan@nxp.com>
