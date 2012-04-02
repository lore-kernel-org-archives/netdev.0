From: Arnd Bergmann <arnd-r2nGTMty4D4@public.gmane.org>
Subject: Re: [PATCH 4/7] arm: mach-pnx4008: Adjust i2c.c to updated i2c-pnx.c
Date: Mon, 2 Apr 2012 13:07:15 +0000
Message-ID: <201204021307.16072.arnd@arndb.de>
References: <1333371364-21347-1-git-send-email-stigge@antcom.de> <1333371364-21347-5-git-send-email-stigge@antcom.de>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-15"
Content-Transfer-Encoding: 7bit
Cc: arm-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org, linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org,
	linux-i2c-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	w.sang-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org, srinivas.bakki-3arQi8VN3Tc@public.gmane.org, kevin.wells-3arQi8VN3Tc@public.gmane.org,
	gregkh-hQyY1W1yCW8ekmWlsbkhG0B+6BGkLq7r@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	rtc-linux-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org, a.zummo-BfzFCNDTiLLj+vYz1yj4TQ@public.gmane.org,
	linux-watchdog-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, wim-IQzOog9fTRqzQB+pC5nmwQ@public.gmane.org
To: Roland Stigge <stigge-uj/7R2tJ6VmzQB+pC5nmwQ@public.gmane.org>
Return-path: <linux-i2c-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1333371364-21347-5-git-send-email-stigge-uj/7R2tJ6VmzQB+pC5nmwQ@public.gmane.org>
Sender: linux-i2c-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Monday 02 April 2012, Roland Stigge wrote:
> The i2c bus driver i2c-pnx.c (used by mach-pnx4008 and mach-lpc32xx) was
> updated to support device tree. In this process, the struct i2c_pnx_data was
> eliminated. Therefore, the platform data of pnx4008 is adjusted with this patch
> to use default resources for mem and irq. DT support for pnx4008 is still not
> available, but i2c-pnx.c now supports both DT and non-DT.
> 
> arch/arm/mach-pnx4008/include/mach/i2c.h can safely be removed now since its
> contents is integrated in the updated i2c-pnx.c driver and was duplicated
> between platforms pnx4008 and lpc32xx.
> 
> Signed-off-by: Roland Stigge <stigge-uj/7R2tJ6VmzQB+pC5nmwQ@public.gmane.org>

Hi Roland,

The i2c changes look ok, but the order breaks bisection through the series.

Since the changes in pnx4008 are fairly localized, I would suggest merging
all three patches through the i2c tree and reorganizing the changes so
that each change is atomic. I would suggest an order like:

1. fix suspend
2. move contents of mach/i2c.h from pnx4008 and lpc32xx to i2c driver
3. change driver and platform device definitions to use resources instead
   of platform data
4. add support for device tree based probing

	Arnd
