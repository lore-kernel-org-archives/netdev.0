From: Jussi Kivilinna <jussi.kivilinna-E01nCVcF24I@public.gmane.org>
Subject: Re: [PATCH 6/8] [PATCH] Split up rndis_host.c
Date: Thu, 17 Jan 2008 22:40:30 +0200
Message-ID: <1200602430.16510.0.camel@localhost>
References: <11983602942818-git-send-email-bjd@jooz.net>
	 <20071223011707.1798C2360C6@adsl-69-226-248-13.dsl.pltn13.pacbell.net>
	 <1199304827.8532.31.camel@localhost>
	 <200801080319.23299.david-b@pacbell.net>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: bjd-a1rhEgazXTw@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: David Brownell <david-b-yBeKhBN/0LDR7s880joybQ@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <200801080319.23299.david-b-yBeKhBN/0LDR7s880joybQ@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Tue, 2008-01-08 at 03:19 -0800, David Brownell wrote:
> > Our 
> > module version checks OID_GEN_PHYSICAL_MEDIUM in generic_rndis_bind,
> > with rndis_host bind fails if OID is supported and wireless media
type
> > is returned, with rndis_wext if OID isn't supported or type isn't
> > wireless. Should this be ok?
> 
> Sounds like if you can go the different-modules route, then
rndis_bind()
> should maybe accept a parameter giving it that option.  Then
> 
>       rndis_wlan_bind(...) == rndis_bind(..., check_wlan_media)
>       rndis_generic_bind(...) == rndis_bind(..., non_wlan_media)
> 
> That would be getting pretty complicated, since as you say the same
> USB-level binding (hence hotplugging) would need to kick in ... but
> having different modules for different RNDIS flavors would need a 
> new hotplug mechanism keying on media type.  Ugh.

Different modules works with rndis_generic_bind(..., media type option).
dmesg shows following:

[11214.496773] usb 3-3: new high speed USB device using ehci_hcd and
address 7
[11214.622861] usb 3-3: configuration #1 chosen from 1 choice
[11214.784874] usbcore: registered new interface driver cdc_ether
[11214.805700] rndis_host 3-3:1.0: driver requires wired physical
medium, but device is wireless.
[11214.806823] usbcore: registered new interface driver rndis_host
[11215.190824] wlan0: register 'rndis_wext' at usb-0000:00:10.3-3,
Wireless RNDIS device, 00:xx:xx:xx:xx:xx
[11215.190853] usbcore: registered new interface driver rndis_wext
[11215.398850] rndis_wext 3-3:1.0: rndis media disconnect

I assume that rndis_host gets always bind first as it's first in
alphabetic, so rndis_wext is only loaded if RNDIS device has wireless
media type.

I have new patchset that prepares rndis_host/usbnet for separate
rndis_wext but not sure should I submit (I haven't managed to get into
contact with Bjorge Dijkstra for 3,5 weeks now to have him decide how to
proceed). 

 - Jussi Kivilinna
