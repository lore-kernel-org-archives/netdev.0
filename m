From: Christoph Hellwig <hch-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org>
Subject: Re: [PATCH #2] Merge the Sonics Silicon Backplane subsystem
Date: Sat, 14 Jul 2007 18:26:05 +0100
Message-ID: <20070714172605.GA15586@infradead.org>
References: <200707141918.22457.mb@bu3sch.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>,
	John Linville <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>,
	Aurelien Jarno <aurelien-rXXEIb44qovR7s880joybQ@public.gmane.org>,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Gary Zambrano <zambrano-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Michael Buesch <mb-fseUSCV1ubazQB+pC5nmwQ@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <200707141918.22457.mb-fseUSCV1ubazQB+pC5nmwQ@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Sat, Jul 14, 2007 at 07:18:20PM +0200, Michael Buesch wrote:
> --- /dev/null
> +++ b/drivers/ssb/Makefile
> @@ -0,0 +1,11 @@
> +ssb-builtin-drivers-y					+= driver_chipcommon.o
> +ssb-builtin-drivers-$(CONFIG_SSB_DRIVER_MIPS)		+= driver_mipscore.o
> +ssb-builtin-drivers-$(CONFIG_SSB_DRIVER_PCICORE)	+= driver_pcicore.o
> +
> +ssb-hostsupport-$(CONFIG_SSB_PCIHOST)			+= pci.o pcihost_wrapper.o
> +ssb-hostsupport-$(CONFIG_SSB_PCMCIAHOST)		+= pcmcia.o
> +
> +obj-$(CONFIG_SSB) += ssb.o
> +
> +ssb-objs	:= main.o scan.o \
> +		   $(ssb-hostsupport-y) $(ssb-builtin-drivers-y)

Whoa, this makefile is more than ugly :)

Please try something like:

# core
ssb-y					+= main.o scan.o

# host support
ssb-$(CONFIG_SSB_PCIHOST)		+= pci.o pcihost_wrapper.o
ssb-$(CONFIG_SSB_PCMCIAHOST)		+= pcmcia.o

# drivers
ssb-y					+= driver_chipcommon.o
ssb-$(CONFIG_SSB_DRIVER_MIPS)		+= driver_mipscore.o
ssb-$(CONFIG_SSB_DRIVER_PCICORE)	+= driver_pcicore.o

obj-$(CONFIG_SSB)			+= ssb.o

instead


> +	default y

please don't add defauly y statements for random drivers.
