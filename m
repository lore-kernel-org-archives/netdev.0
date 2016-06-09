From: Lucas Stach <l.stach-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>
Subject: Re: [PATCH v2 1/2] ARM: imx6: disable deeper idle states when FEC
 is active w/o HW workaround
Date: Thu, 09 Jun 2016 11:35:24 +0200
Message-ID: <1465464924.18807.5.camel@pengutronix.de>
References: <1464971480-9203-1-git-send-email-l.stach@pengutronix.de>
	 <VI1PR0401MB1855AA40FA576AF677A68E6FFF5C0@VI1PR0401MB1855.eurprd04.prod.outlook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"patchwork-lst-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org" <patchwork-lst-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>,
	"kernel-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org" <kernel-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>,
	"linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org"
	<linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org>,
	"netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Fugang Duan <fugang.duan-3arQi8VN3Tc@public.gmane.org>, Shawn Guo <shawnguo-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <VI1PR0401MB1855AA40FA576AF677A68E6FFF5C0-9IDQY6o3qQgSuE83DPDYPY3W/0Ik+aLCnBOFsp37pqbUKgpGm//BTAC/G2K4zDHf@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hi Fugang,

Am Montag, den 06.06.2016, 02:00 +0000 schrieb Fugang Duan:
> From: Lucas Stach <l.stach-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org> Sent: Saturday, June 04,
> 2016 12:31 AM
> > 
> > To: Shawn Guo <shawnguo-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>; Fugang Duan <fugang.duan@nxp.c
> > om>
> > Cc: devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org; patchwork-lst-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org;
> > kernel-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org; linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org;
> > netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
> > Subject: [PATCH v2 1/2] ARM: imx6: disable deeper idle states when
> > FEC is
> > active w/o HW workaround
> > 
> > The i.MX6 Q/DL has an erratum (ERR006687) that prevents the FEC
> > from waking
> > the CPUs when they are in wait(unclocked) state. As the hardware
> > workaround
> > isn't applicable to all boards, disable the deeper idle state when
> > the workaround
> > isn't present and the FEC is in use.
> > 
> > This allows to safely run a kernel with CPUidle enabled on all
> > i.MX6 boards.
> > 
> > Signed-off-by: Lucas Stach <l.stach-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>
> > Acked-by: David S. Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org> (for network
> > changes)
> > ---

[...]

> Hi, Lucas,
> 
> FEC irq cannot wake up CPUs when system is in wait mode. But we can
> use GPIO_6 for FEC interrupt that GPIO irq wake up CPUs.
> No need to disable wait mode as your such patches.
> 
> You just config the gpio irq like below patches:
> bc20a5d6da71 (ARM: dts: imx6qdl-sabreauto: use GPIO_6 for FEC
> interrupt.)
> 6261c4c8f13e (ARM: dts: imx6qdl-sabrelite: use GPIO_6 for FEC
> interrupt.)
> 
Please look at the description of this series again. The changes don't
disable the deeper idle states on boards where the HW waorkaround is
available. There is a large number of boards in the wild which can not
use the HW workaround, as they use GPIO_6 for other purposes. The aim
of this series is to have an automatic software workaround available
for those boards.

Regards,
Lucas
--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
