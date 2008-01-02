From: Jussi Kivilinna <jussi.kivilinna-E01nCVcF24I@public.gmane.org>
Subject: Re: [PATCH 6/8] [PATCH] Split up rndis_host.c
Date: Wed, 02 Jan 2008 22:13:47 +0200
Message-ID: <1199304827.8532.31.camel@localhost>
References: <11983602942818-git-send-email-bjd@jooz.net>
	 <11983602953056-git-send-email-bjd@jooz.net>
	 <20071223011707.1798C2360C6@adsl-69-226-248-13.dsl.pltn13.pacbell.net>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: bjd-a1rhEgazXTw@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: David Brownell <david-b-yBeKhBN/0LDR7s880joybQ@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20071223011707.1798C2360C6-ZcXrCSuhvln6VZ3dlLfH/g4gEjPzgfUyLrfjE7I9kuVHxeISYlDBzl6hYfS7NtTn@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hello,

Bjorge was not comfortable with double probing rndis_wext requires,
wireless RNDIS devices have same device id as the rest of RNDIS. Our
module version checks OID_GEN_PHYSICAL_MEDIUM in generic_rndis_bind,
with rndis_host bind fails if OID is supported and wireless media type
is returned, with rndis_wext if OID isn't supported or type isn't
wireless. Should this be ok?

Should separate rndis_wext be located in drivers/net/wireless instead of
drivers/net/usb?

 - Jussi Kivilinna

On Sat, 2007-12-22 at 17:17 -0800, David Brownell wrote:
> > From: Bjorge Dijkstra <bjd-a1rhEgazXTw@public.gmane.org>
> > Subject: [PATCH 6/8] [PATCH] Split up rndis_host.c
> > Date: Sat, 22 Dec 2007 22:51:32 +0100
> >
> > Split up rndis_host.c into rndis_host.h and rndis_base.c and
> > change Makefile accordingly. This is done so we can add extra
> > source files to the rndis_host module later on.
> 
> I'm fine with splitting out a header file and the EXPORT_SYMBOL_GPL.
> But why not just have a separate "rndis_wext" module?
> 
> 
> > ---
> >  drivers/net/usb/Makefile     |    1 +
> >  drivers/net/usb/rndis_base.c |  548 ++++++++++++++++++++++++++++++
> >  drivers/net/usb/rndis_host.c |  763 ------------------------------------------
> >  drivers/net/usb/rndis_host.h |  256 ++++++++++++++
> >  4 files changed, 805 insertions(+), 763 deletions(-)
> >  create mode 100644 drivers/net/usb/rndis_base.c
> >  delete mode 100644 drivers/net/usb/rndis_host.c
> >  create mode 100644 drivers/net/usb/rndis_host.h
> -
> To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
> the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
