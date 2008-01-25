From: David Brownell <david-b@pacbell.net>
Subject: Re: [PATCH 00/14] RFC: Driver for Wireless RNDIS USB devices.
Date: Thu, 24 Jan 2008 17:19:14 -0800
Message-ID: <200801241719.14941.david-b@pacbell.net>
References: <20080120001342.25718.83669.stgit@fate.lan>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: linux-wireless@vger.kernel.org, bjd@jooz.net,
	netdev@vger.kernel.org
To: Jussi Kivilinna <jussi.kivilinna@mbnet.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp115.sbc.mail.sp1.yahoo.com ([69.147.64.88]:36458 "HELO
	smtp115.sbc.mail.sp1.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1754649AbYAYBU3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Jan 2008 20:20:29 -0500
In-Reply-To: <20080120001342.25718.83669.stgit@fate.lan>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Saturday 19 January 2008, Jussi Kivilinna wrote:
> Hello,
> 
> This is second try on wireless RNDIS patchset started by Bjorge Dijkstra. Since
> Bjorge has disappeared, I claim maintainership of rndis_wext and this patchset
> until he returns.
> 
> This patchset adds support for various 802.11 USB devices based on Broadcom
> 4320 chip. Chip uses RNDIS to communicate with the host, so module depend
> heavily on rndis_host/cdc_ether/usbnet and needs some changes on these 
> modules in order to work.
> 
> Patches 1-6 are from first patchset:
>  1. Fix sparse warning: returning void valued expression
>  2. [cdc_ether] Hardwire CDC descriptors when missing
>  3. [rndis_host] Use 1KB buffer in rndis_unbind
>  4. [rndis_host] Halt device if rndis_bind fails
>  5. [rndis_host] Fix rndis packet filter flags
>  6. [usbnet] Use wlan device name for RNDIS wireless devices
> 
> Of these 1, 3 and 4 are not required for this version of rndis_wext to work.
> 
> Actual wireless part is changed from extension on rndis_host to separate 
> driver. Different devices are detected by device specific USB vendor/product 
> IDs as the way done with Windows drivers instead of detecting RNDIS media type 
> like in first patchset.
> 
> New patches 7-14:
>  7. [rndis_host] Split up rndis_host.c
>  8. [rndis_host] export functions
>  9. [usbnet] add driver_priv pointer to 'struct usbnet'

So far as I'm concerned patches 1-9 can go in any time.

The other patches I won't ack yet; see below.


> 10. [rndis_host] Add rndis_early_init function pointer to 'struct rndis_data'.
> 11. [rndis_host] Add rndis_link_change function pointer to 'struct rndis_data'.

Those aren't added to "struct rndis_data" ... they're added to
the struct at the core of the usbnet framework.  So they should
not be RNDIS-specific ... even though the only current user will
be the RNDIS host code.  Rename those methods and I'll be happy.


> 12. Move usbnet.h and rndis_host.h to include/linux/usb

No problem with that, except that fixing #10 and #11 will
break them.


> 13. [rndis_host] blacklist known wireless RNDIS devices

That will be a headache over time though ... can't you just
let the probe succeed enough to recogize it's wireless (using
the media flag) and then bail, so the next driver can try?


> 14. Add new driver 'rndis_wext' for wireless RNDIS devices.

The real goods!  :)

 
> Patches should be applied in order, series apply cleanly to 2.6.24-rc8.
> 
>  - Jussi Kivilinna
> 


